{
  pkgs,
  config,
  ...
}:
let
  displayBrightness = pkgs.writeShellScriptBin "displayBrightness" ''
    MAX_TIME_STRING="${config.myhome.display.brightness.maxTime}"
    MIN_TIME_STRING="${config.myhome.display.brightness.minTime}"
    step=50

    # Bash array of monitors interpolated from Nix list
    monitor_models=(
      ${builtins.concatStringsSep "\n  " (map (mon: ''"${mon.model}"'') config.myhome.display.monitors)}
    )

    get_current_brightness() {
      local monitor=$1
      ddcutil get 10 --model "$monitor" | cut -d, -f1 | cut -d= -f2 | xargs
    }

    set_brightness() {
      local monitor=$1
      local value=$2
      ddcutil set 10 --model "$monitor" "$value"
    }

    notify() {
      local value=$1
      notify-send "Brightness set to ''${value}%" --hint=int:transient:1
    }

    # Helper: current time in minutes since midnight (00:00 -> 0)
    time_now_minutes() {
      local h m
      h=$(date +%H)
      m=$(date +%M)
      echo $((10#$h * 60 + 10#$m))
    }

    # Compute time -> minutes parser using date to avoid fragile expansion
    parse_time_to_minutes() {
      local t="$1"
      local parsed h m
      if parsed=$(date -d "$t" "+%H %M" 2>/dev/null); then
        read h m <<<"$parsed"
      else
        h=0; m=0
      fi
      echo $((10#$h * 60 + 10#$m))
    }

    MAX_START=$(parse_time_to_minutes "$MAX_TIME_STRING")
    MIN_START=$(parse_time_to_minutes "$MIN_TIME_STRING")

    COOLDOWN_SECONDS=10
    STATE_FILE="/run/user/$(id -u)/displayBrightness.state"

    reference_monitor="''\${monitor_models[0]}"
    current=$(get_current_brightness "$reference_monitor")

    ACTION="$1"
    if [ "$1" = "auto" ]; then
      now_minutes=$(time_now_minutes)
      if [ "$MAX_START" -le "$MIN_START" ]; then
        if [ "$now_minutes" -ge "$MAX_START" ] && [ "$now_minutes" -lt "$MIN_START" ]; then
          ACTION=max
        else
          ACTION=min
        fi
      else
        if [ "$now_minutes" -ge "$MAX_START" ] || [ "$now_minutes" -lt "$MIN_START" ]; then
          ACTION=max
        else
          ACTION=min
        fi
      fi

      now_ts=$(date +%s)
      if [ -f "$STATE_FILE" ]; then
        read last_ts last_mode < "$STATE_FILE" || true
        if [ -n "$last_ts" ]; then
          delta=$((now_ts - last_ts))
          if [ "$delta" -lt "$COOLDOWN_SECONDS" ]; then
            exit 0
          fi
        fi
      fi
    fi

    case "$ACTION" in
      min)
        if [ "$current" -eq 0 ]; then exit 0; fi
        future=0
        ;;
      max)
        if [ "$current" -eq 100 ]; then exit 0; fi
        future=100
        ;;
      increase)
        future=$((current + step))
        if [ "$future" -gt 100 ]; then future=100; fi
        if [ "$current" -eq "$future" ]; then exit 0; fi
        ;;
      decrease)
        future=$((current - step))
        if [ "$future" -lt 0 ]; then future=0; fi
        if [ "$current" -eq "$future" ]; then exit 0; fi
        ;;
      *)
        echo "Usage: $0 {min|max|increase|decrease}"
        exit 1
        ;;
    esac

    for monitor in "''\${monitor_models[@]}"; do
      set_brightness "$monitor" "$future"
    done
    notify "$future"

    if [ "${"ACTION:-"}" = "min" ] || [ "${"ACTION:-"}" = "max" ]; then
      now_ts=$(date +%s)
      printf "%s %s\n" "$now_ts" "$ACTION" > "$STATE_FILE" 2>/dev/null || true
    fi

  '';

in
{
  systemd.user.services.displayBrightness = {
    Unit = {
      Description = "Display brightness helper";
    };
    Service = {
      ExecStart = "${displayBrightness}/bin/displayBrightness auto";
      Type = "oneshot";
    };
  };

  systemd.user.timers =
    (
      if
        config.myhome.display.brightness.maxTime != null && config.myhome.display.brightness.maxTime != ""
      then
        {
          displayBrightnessMax = {
            Unit.Description = "timer for displayBrightness service";
            Timer = {
              Unit = "displayBrightness.service";
              OnCalendar = "*-*-* ${config.myhome.display.brightness.maxTime}";
              Persistent = false;
            };
            Install.WantedBy = [ "timers.target" ];
          };
        }
      else
        { }
    )
    // (
      if
        config.myhome.display.brightness.minTime != null && config.myhome.display.brightness.minTime != ""
      then
        {
          displayBrightnessMin = {
            Unit.Description = "timer for displayBrightness service";
            Timer = {
              Unit = "displayBrightness.service";
              OnCalendar = "*-*-* ${config.myhome.display.brightness.minTime}";
              Persistent = false;
            };
            Install.WantedBy = [ "timers.target" ];
          };
        }
      else
        { }
    );

  home.packages = [ displayBrightness ];
}
