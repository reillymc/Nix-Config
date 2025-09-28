{
  pkgs,
  lib,
  configDir,
  ...
}:

let
  toggleMicrophone = pkgs.writeShellScriptBin "toggleMicrophone" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

  cycleAudioOutput = pkgs.writeShellScriptBin "cycleAudioOutput" ''
    SOUND="${configDir}/resources/sounds/audioOutputToggle.ogg"

    declare -a AUDIO_DEVICES=(
      "bluez_output.94_DB_56_D5_A1_18.1"  # Bluetooth Headphones # TODO: make configurable
      "bluez_output.6C_5C_3D_39_AD_2A.1"  # Bluetooth Speakers
    )

    notify_and_play_sound() {
      local label="$1"
      notify-send "$label Activated" --hint=int:transient:1
      pw-play "$SOUND" &
    }

    get_current_sink_id() {
      wpctl status -n | awk '
        $2 == "*" {
          sub(/\./, "", $3)
          print $3
          exit
        }
      '
    }

    get_sink_name_by_id() {
      local id="$1"
      wpctl status -n | awk -v id="$id" '
        $3 == id"." { print $4; exit }
      '
    }

    get_sink_id_by_name() {
      local name="$1"
      wpctl status -n | awk -v n="$name" '
        $0 ~ n {
          for (i = 1; i <= NF; i++) {
            if ($i ~ /^[0-9]+\.$/) {
              sub(/\./, "", $i)
              print $i
              exit
            }
          }
        }
      '
    }

    connect_bluetooth_if_needed() {
      local sink_name="$1"

      if [[ "$sink_name" =~ ^bluez_output\.([0-9A-Fa-f_]+)\. ]]; then
        local mac_underscored="''\${BASH_REMATCH[1]}"
        local bt_mac="''\${mac_underscored//_/':'}"

        echo "Attempting to connect to Bluetooth device: $bt_mac"

        if ! bluetoothctl info "$bt_mac" | grep -q "Connected: yes"; then
          echo -e "connect $bt_mac\nquit" | bluetoothctl > /dev/null
        fi

        for i in {1..10}; do
          if bluetoothctl info "$bt_mac" | grep -q "Connected: yes"; then
            echo "Bluetooth device connected."
            break
          fi
          echo "Waiting for Bluetooth connection... ($i/10)"
          sleep 1
        done

        local timeout=20
        local elapsed=0
        while [[ $elapsed -lt $timeout ]]; do
          local sink_id
          sink_id=$(get_sink_id_by_name "$sink_name")

          if [[ -n "$sink_id" && "$sink_id" =~ ^[1-9][0-9]*$ ]]; then
            echo "Audio sink available: $sink_name (ID: $sink_id)"
            return 0
          fi

          echo "Waiting for sink to register... ($elapsed/$timeout)"
          sleep 1
          ((elapsed++))
        done

        echo "Sink $sink_name not found after waiting. Current sinks:"
        wpctl status -n

        return 1
      fi

      return 0
    }

    cycle_audio_devices() {
      local current_id current_name index=-1 next_index next_name next_id
      current_id=$(get_current_sink_id)

      if [[ -z "$current_id" ]]; then
        notify-send "Could not determine current default sink"
        exit 1
      fi

      current_name=$(get_sink_name_by_id "$current_id")

      local device_count="''\${#AUDIO_DEVICES[@]}"
      for (( i=0; i < $device_count; i++ )); do
        if [[ "''\${AUDIO_DEVICES[$i]}" == "$current_name" ]]; then
          index=$i
          break
        fi
      done

      if [[ $index -eq -1 ]]; then
        index=0
      fi

      for (( offset=1; offset <= $device_count; offset++ )); do
        next_index=$(( (index + offset) % $device_count ))
        next_name="''\${AUDIO_DEVICES[$next_index]}"

        echo "Attempting to switch to: $next_name"

        if ! connect_bluetooth_if_needed "$next_name"; then
          echo "Bluetooth connection failed for: $next_name"
          continue
        fi

        next_id=$(get_sink_id_by_name "$next_name")

        if [[ -z "$next_id" || ! "$next_id" =~ ^[1-9][0-9]*$ ]]; then
          echo "Sink ID invalid or not found for: $next_name (got: '$next_id')"
          wpctl status -n
          continue
        fi

        if wpctl set-default "$next_id"; then
          notify_and_play_sound "$next_name"
          return 0
        else
          echo "Failed to switch to sink ID $next_id for $next_name"
          continue
        fi
      done

      notify-send "Failed to switch to any audio device"
      exit 1
    }

    cycle_audio_devices
  '';
in
{
  options.scripts.toggleMicrophone = lib.mkOption {
    type = lib.types.str;
    description = "Microphone toggle script";
    default = "${toggleMicrophone}/bin/toggleMicrophone";
  };
  options.scripts.cycleAudioOutput = lib.mkOption {
    type = lib.types.str;
    description = "Audio output cycle script";
    default = "${cycleAudioOutput}/bin/cycleAudioOutput";
  };
}
