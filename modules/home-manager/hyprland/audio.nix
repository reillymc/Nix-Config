{
  pkgs,
  lib,
  config,
  configDir,
  ...
}:

let
  toggleMicrophone = pkgs.writeShellApplication {
    name = "toggleMicrophone";

    runtimeInputs = [
      pkgs.wireplumber
    ];

    text = ''
      set -euo pipefail

      wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    '';
  };

  cycleAudioOutput = pkgs.writeShellApplication {
    name = "cycleAudioOutput";

    runtimeInputs = [
      pkgs.wireplumber
      pkgs.libnotify
      pkgs.pipewire
      pkgs.bluez
      pkgs.gawk
      pkgs.gnugrep
      pkgs.coreutils
    ];

    text = ''
      set -euo pipefail

      SOUND="${configDir}/resources/sounds/audioOutputToggle.ogg"

      AUDIO_DEVICES=(
      ${lib.concatStringsSep "\n" (map (d: ''"${d}"'') (config.myhome.audio.devices or [ ]))}
      )

      log() {
        printf '[cycleAudioOutput] %s\n' "$*" >&2
      }

      notify_switch() {
        pw-play --volume=0.25 "$SOUND" >/dev/null 2>&1 &
        disown || true
      }

      wpctl_status() {
        wpctl status -n
      }

      current_sink_id() {
        wpctl_status | awk '
          $2=="*" {
            gsub(/\./,"",$3)
            print $3
            exit
          }
        '
      }

      sink_name() {
        local id="$1"

        wpctl_status | awk -v id="$id" '
          $3 == id"." {
            print $4
            exit
          }
        '
      }

      sink_id() {
        local name="$1"

        wpctl_status | awk -v target="$name" '
          index($0,target) {
            for(i=1;i<=NF;i++) {
              if ($i ~ /^[0-9]+\.$/) {
                gsub(/\./,"",$i)
                print $i
                exit
              }
            }
          }
        '
      }

      connect_bluetooth() {
        local sink="$1"

        [[ "$sink" =~ ^bluez_output\.([0-9A-Fa-f_]+)\. ]] || return 0

        local mac
        mac="''${BASH_REMATCH[1]//_/:}"

        log "Connecting $mac"

        bluetoothctl connect "$mac" >/dev/null || true

        for ((i=0;i<10;i++)); do
          if bluetoothctl info "$mac" \
            | grep -q "Connected: yes"
          then
            return 0
          fi

          sleep 1
        done

        return 1
      }

      switch_sink() {
        local sink="$1"

        connect_bluetooth "$sink" || return 1

        local id

        for ((i=0;i<20;i++)); do
          id=$(sink_id "$sink")

          if [[ "$id" =~ ^[0-9]+$ ]]; then
            wpctl set-default "$id"

            notify_switch

            return 0
          fi

          sleep 1
        done

        return 1
      }

      current=$(current_sink_id)

      [[ -n "$current" ]] || {
        notify-send "No active audio output"
        exit 1
      }

      active=$(sink_name "$current")

      idx=-1

      for i in "''${!AUDIO_DEVICES[@]}"; do
        if [[ "''${AUDIO_DEVICES[$i]}" == "$active" ]]; then
          idx="$i"
          break
        fi
      done

      (( idx < 0 )) && idx=0

      count="''${#AUDIO_DEVICES[@]}"

      for ((offset=1; offset<=count; offset++)); do

        candidate=$(( (idx + offset) % count ))

        if switch_sink \
          "''${AUDIO_DEVICES[$candidate]}"
        then
          exit 0
        fi

      done

      notify-send "No audio device available"

      exit 1
    '';
  };
in
{
  home.packages = [
    cycleAudioOutput
    toggleMicrophone
  ];
}
