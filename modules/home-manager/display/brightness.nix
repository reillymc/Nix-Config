{
  pkgs,
  config,
  lib,
  ...
}:
let
  needsBrightnessctl = lib.any (mon: mon.control == "brightnessctl") config.myhome.display.monitors;

  needsDdcutil = lib.any (mon: mon.control == "ddcutil") config.myhome.display.monitors;

  displayBrightness = pkgs.writeShellScriptBin "displayBrightness" ''
    MAX_TIME_STRING="${config.myhome.display.brightness.maxTime}"
    MIN_TIME_STRING="${config.myhome.display.brightness.minTime}"
    step=50

    # Bash array of monitors and control methods interpolated from Nix list
    monitor_entries=(
      ${builtins.concatStringsSep "\n  " (
        map (
          mon: ''"${mon.output}|${if mon.control != null then mon.control else ""}"''
        ) config.myhome.display.monitors
      )}
    )

    is_internal_monitor() {
      case "$1" in
        eDP*|LVDS*|DSI*) return 0 ;;
        *) return 1 ;;
      esac
    }

    get_current_brightness() {
      local monitor="$1"
      local control="$2"

      if [ -z "$control" ]; then
        if is_internal_monitor "$monitor"; then
          control="brightnessctl"
        else
          control="ddcutil"
        fi
      fi

      if [ "$control" = "brightnessctl" ]; then
        if current=$(brightnessctl get 2>/dev/null) && max=$(brightnessctl max 2>/dev/null) && [ -n "$current" ] && [ -n "$max" ] && [ "$max" -gt 0 ]; then
          echo $((current * 100 / max))
          return
        fi
      fi

      ddcutil get 10 --model "$monitor" | cut -d, -f1 | cut -d= -f2 | xargs
    }

    set_brightness() {
      local monitor="$1"
      local control="$2"
      local value="$3"

      if [ -z "$control" ]; then
        if is_internal_monitor "$monitor"; then
          control="brightnessctl"
        else
          control="ddcutil"
        fi
      fi

      if [ "$control" = "brightnessctl" ]; then
        if max=$(brightnessctl max 2>/dev/null) && [ -n "$max" ] && [ "$max" -gt 0 ]; then
          local target=$((value * max / 100))
          brightnessctl set "$target" >/dev/null 2>&1 && return
        fi
      fi

      ddcutil set 10 --model "$monitor" "$value"
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

    reference_entry="$${monitor_entries[0]}"
    IFS='|' read -r reference_monitor reference_control <<< "$reference_entry"
    current=$(get_current_brightness "$reference_monitor" "$reference_control")

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

    for entry in "$${monitor_entries[@]}"; do
      IFS='|' read -r monitor control <<< "$entry"
      set_brightness "$monitor" "$control" "$future"
    done

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

  systemd.user.timers.displayBrightnessMax =
    lib.mkIf (config.myhome.display.brightness.maxTime != null)
      {

        Unit.Description = "timer for displayBrightness service";
        Timer = {
          Unit = "displayBrightness.service";
          OnCalendar = "*-*-* ${config.myhome.display.brightness.maxTime}:00";
          Persistent = false;
        };
        Install.WantedBy = [ "timers.target" ];
      };

  systemd.user.timers.displayBrightnessMin =
    lib.mkIf (config.myhome.display.brightness.minTime != null)
      {
        Unit.Description = "timer for displayBrightness service";
        Timer = {
          Unit = "displayBrightness.service";
          OnCalendar = "*-*-* ${config.myhome.display.brightness.minTime}:00";
          Persistent = false;
        };
        Install.WantedBy = [ "timers.target" ];
      };

  home.packages = [
    displayBrightness
  ]
  ++ lib.optional needsBrightnessctl pkgs.brightnessctl
  ++ lib.optional needsDdcutil pkgs.ddcutil;
}
