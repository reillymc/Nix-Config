{
  pkgs,
  config,
  lib,
  ...
}:
let
  controls = lib.unique (map (m: m.control) config.myhome.display.monitors);

  controlPackages = {
    inherit (pkgs) brightnessctl;
    inherit (pkgs) ddcutil;
  };

  displayBrightness = pkgs.writeShellApplication {
    name = "displayBrightness";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
    ]
    ++ map (c: controlPackages.${c}) controls;

    text = ''
      set -euo pipefail

      MAX_TIME_STRING="${config.myhome.display.brightness.maxTime}"
      MIN_TIME_STRING="${config.myhome.display.brightness.minTime}"

      BRIGHTNESS_EXPONENT=3
      STEP=${toString (config.myhome.display.brightness.step or 20)}

      COOLDOWN_SECONDS=10
      STATE_FILE="/run/user/$(id -u)/displayBrightness.state"

      # ----------------------------
      # Monitor data from Nix
      # ----------------------------
      MONITOR_OUTPUTS=(
      ${builtins.concatStringsSep "\n" (map (m: ''"${m.output}"'') config.myhome.display.monitors)}
      )

      MONITOR_MODELS=(
      ${builtins.concatStringsSep "\n" (map (m: ''"${m.model}"'') config.myhome.display.monitors)}
      )

      MONITOR_CONTROLS=(
      ${builtins.concatStringsSep "\n" (map (m: ''"${m.control}"'') config.myhome.display.monitors)}
      )

      # ----------------------------
      # Logging
      # ----------------------------
      log() {
        printf '[displayBrightness] %s\n' "$*" >&2
      }

      die() {
        log "ERROR: $*"
        exit 1
      }

      # ----------------------------
      # Time helpers
      # ----------------------------
      time_now_minutes() {
        local h m
        h=$(date +%H)
        m=$(date +%M)
        echo $((10#$h * 60 + 10#$m))
      }

      parse_time_to_minutes() {
        local t="$1"
        local parsed h m

        if parsed=$(date -d "$t" "+%H %M" 2>/dev/null); then
          read -r h m <<< "$parsed"
        else
          h=0
          m=0
        fi

        echo $((10#$h * 60 + 10#$m))
      }

      MAX_START=$(parse_time_to_minutes "$MAX_TIME_STRING")
      MIN_START=$(parse_time_to_minutes "$MIN_TIME_STRING")

      is_daytime() {
        local now="$1"

        if (( MAX_START <= MIN_START )); then
          (( now >= MAX_START && now < MIN_START ))
        else
          (( now >= MAX_START || now < MIN_START ))
        fi
      }

      # ----------------------------
      # Auto mode logic
      # ----------------------------
      resolve_auto_action() {
        local now
        now=$(time_now_minutes)

        if is_daytime "$now"; then
          echo max
        else
          echo min
        fi
      }

      # ----------------------------
      # Cooldown
      # ----------------------------
      cooldown_check() {
        local now_ts last_ts delta

        now_ts=$(date +%s)

        [[ -f "$STATE_FILE" ]] || return 0

        read -r last_ts _ < "$STATE_FILE" || return 0
        [[ -n "$last_ts" ]] || return 0

        delta=$((now_ts - last_ts))
        (( delta >= COOLDOWN_SECONDS ))
      }

      save_state() {
        local mode="$1"

        printf "%s %s\n" "$(date +%s)" "$mode" > "$STATE_FILE" 2>/dev/null || true
      }

      logical_to_physical() {
        local logical="$1"

        (( logical <= 0 )) && {
          echo 0
          return
        }

        (( logical >= 100 )) && {
          echo 100
          return
        }

        awk \
          -v v="$logical" \
          -v e="$BRIGHTNESS_EXPONENT" \
          'BEGIN {
            printf "%.0f\n", ((v / 100) ^ e) * 100
          }'
      }

      physical_to_logical() {
        local physical="$1"

        (( physical <= 0 )) && {
          echo 0
          return
        }

        (( physical >= 100 )) && {
          echo 100
          return
        }

        awk \
          -v v="$physical" \
          -v e="$BRIGHTNESS_EXPONENT" \
          'BEGIN {
            printf "%.0f\n", (v / 100) ^ (1 / e) * 100
          }'
      }

      # ----------------------------
      # Brightness backends
      # ----------------------------
      get_brightness() {
        local _output="$1"
        local model="$2"
        local control="$3"

        case "$control" in
          brightnessctl)
            local current max physical

            current=$(brightnessctl get 2>/dev/null) || return 1
            max=$(brightnessctl max 2>/dev/null) || return 1

            [[ "$max" -gt 0 ]] || return 1

            physical=$((current * 100 / max))

            physical_to_logical "$physical"
            ;;

          ddcutil)
            local line physical

            line=$(ddcutil getvcp 10 --model "$model" 2>/dev/null) || return 1

            [[ "$line" =~ current\ value[[:space:]]*=[[:space:]]*([0-9]+) ]] || return 1

            physical="''${BASH_REMATCH[1]}"

            physical_to_logical "$physical"
            ;;

          *)
            return 1
            ;;
        esac
      }

      set_brightness() {
        local _output="$1"
        local model="$2"
        local control="$3"
        local value="$4"

        case "$control" in
          brightnessctl)
            brightnessctl \
              --exponent="$BRIGHTNESS_EXPONENT" \
              set "$value%" \
              >/dev/null 2>&1
            ;;

          ddcutil)
            local physical

            physical=$(logical_to_physical "$value")

            ddcutil setvcp 10 "$physical" \
              --model "$model" \
              >/dev/null 2>&1
            ;;

          *)
            return 1
            ;;
        esac
      }

      # ----------------------------
      # Core logic
      # ----------------------------
      get_reference_brightness() {
        local i brightness

        for ((i = 0; i < ''${#MONITOR_OUTPUTS[@]}; i++)); do

          if brightness=$(
            get_brightness \
              "''${MONITOR_OUTPUTS[$i]}" \
              "''${MONITOR_MODELS[$i]}" \
              "''${MONITOR_CONTROLS[$i]}"
          ); then
            echo "$brightness"
            return 0
          fi

        done

        return 1
      }

      compute_target() {
        local current="$1"
        local action="$2"

        case "$action" in
          min)
            echo 0
            ;;

          max)
            echo 100
            ;;

          increase)
            current=$((current + STEP))
            (( current > 100 )) && current=100
            echo "$current"
            ;;

          decrease)
            current=$((current - STEP))
            (( current < 0 )) && current=0
            echo "$current"
            ;;

          *)
            die "Unknown action: $action"
            ;;
        esac
      }

      apply_brightness() {
        local target="$1"
        local successes=0
        local i

        for ((i = 0; i < ''${#MONITOR_OUTPUTS[@]}; i++)); do

          if set_brightness \
            "''${MONITOR_OUTPUTS[$i]}" \
            "''${MONITOR_MODELS[$i]}" \
            "''${MONITOR_CONTROLS[$i]}" \
            "$target"
          then
            ((successes++))
          else
            log "Skipping unavailable monitor: ''${MONITOR_OUTPUTS[$i]}"
          fi

        done

        ((successes > 0))
      }

      ACTION="''${1:-}"

      [[ -n "$ACTION" ]] || die "Usage: displayBrightness {auto|min|max|increase|decrease}"

      if [[ "$ACTION" == "auto" ]]; then
        ACTION=$(resolve_auto_action)
        cooldown_check || exit 0
      fi

      if ! current=$(get_reference_brightness); then
        die "No responsive monitor brightness controls found"
      fi

      [[ "$current" =~ ^[0-9]+$ ]] || die "Invalid brightness value: $current"

      target=$(compute_target "$current" "$ACTION")

      [[ "$target" != "$current" ]] || exit 0

      if ! apply_brightness "$target"; then
        die "Failed to update any monitor"
      fi

      if [[ "$ACTION" == "min" || "$ACTION" == "max" ]]; then
        save_state "$ACTION"
      fi
    '';
  };
in
{
  systemd.user = {
    services.displayBrightness = {
      Unit = {
        Description = "Display brightness helper";
      };
      Service = {
        ExecStart = "${displayBrightness}/bin/displayBrightness auto";
        Type = "oneshot";
      };
    };
    timers.displayBrightnessMax = lib.mkIf (config.myhome.display.brightness.maxTime != null) {
      Unit.Description = "timer for displayBrightness service";
      Timer = {
        Unit = "displayBrightness.service";
        OnCalendar = "*-*-* ${config.myhome.display.brightness.maxTime}:00";
        Persistent = false;
      };
      Install.WantedBy = [ "timers.target" ];
    };
    timers.displayBrightnessMin = lib.mkIf (config.myhome.display.brightness.minTime != null) {
      Unit.Description = "timer for displayBrightness service";
      Timer = {
        Unit = "displayBrightness.service";
        OnCalendar = "*-*-* ${config.myhome.display.brightness.minTime}:00";
        Persistent = false;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  home.packages = [
    displayBrightness
  ];
}
