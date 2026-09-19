{
  lib,
  pkgs,
}:
{
  disk =
    {
      maxPercent ? 80,
    }:
    pkgs.writeShellScript "metric-disk" ''
      set -eu

      failed=0
      found=0

      while read -r used size capacity target; do
        case "$capacity" in
          *%) ;;
          *) continue ;;
        esac

        found=$(( found + 1 ))
        percent="''${capacity%\%}"
        echo "$target: $used/$size used (''${percent}%)"
        [ "$percent" -lt ${toString maxPercent} ] || failed=1
      done < <(LC_ALL=C ${lib.getExe' pkgs.coreutils "df"} -h --output=used,size,pcent,target \
        -x tmpfs -x devtmpfs -x overlay -x squashfs -x efivarfs -x ramfs \
        | ${lib.getExe' pkgs.coreutils "tail"} -n +2)

      if [ "$found" -eq 0 ]; then
        echo "no local filesystems found"
        failed=1
      fi

      exit "$failed"
    '';

  failedUnits = pkgs.writeShellScript "metric-failed-units" ''
    set -eu

    failed="$(${lib.getExe' pkgs.systemd "systemctl"} --failed --no-legend --plain --no-pager 2>/dev/null | ${lib.getExe' pkgs.gawk "awk"} '{ print $1 }')"

    if [ -n "$failed" ]; then
      echo "failed units: $failed"
      exit 1
    fi

    echo "no failed units"
  '';

  temperature =
    { sensors }:
    let
      validSensor =
        s:
        builtins.isAttrs s
        && s ? name
        && s ? max
        && builtins.isString s.name
        && builtins.isInt s.max
        && s.max > 0;
    in
    assert lib.assertMsg (
      builtins.isList sensors && sensors != [ ]
    ) "metric-temperature: `sensors` must not be empty";
    assert lib.assertMsg (builtins.all validSensor sensors)
      "metric-temperature: every sensor needs a string `name` and a positive integer `max`";
    pkgs.writeShellScript "metric-temperature" ''
      set -eu

      failed=0

      check_sensor() {
        local chip="$1" limit="$2"
        local found=0 readable=0 peak=0 peak_sensor=""

        for f in /sys/class/hwmon/hwmon*/temp*_input; do
          [ -r "$f" ] || continue
          [ "$(${lib.getExe' pkgs.coreutils "cat"} "''${f%/temp*_input}/name" 2>/dev/null || echo unknown)" = "$chip" ] || continue

          found=$(( found + 1 ))

          local value label sensor
          value="$(${lib.getExe' pkgs.coreutils "cat"} "$f" 2>/dev/null || true)"
          [ -n "$value" ] && [ "$value" -gt 0 ] || continue

          readable=$(( readable + 1 ))

          label="$(${lib.getExe' pkgs.coreutils "cat"} "''${f%_input}_label" 2>/dev/null || true)"
          sensor="$chip ''${label:-$(${lib.getExe' pkgs.coreutils "basename"} "''${f%_input}")}"
          echo "$sensor: $((value / 1000))C"

          if [ "$value" -gt "$peak" ]; then
            peak="$value"
            peak_sensor="$sensor"
          fi
        done

        if [ "$found" -eq 0 ]; then
          echo "$chip: no matching sensors"
          failed=1
          return
        fi

        if [ "$readable" -eq 0 ]; then
          echo "$chip: no readable sensors"
          failed=1
          return
        fi

        echo "$chip peak: $((peak / 1000))C ($peak_sensor)"
        [ "$peak" -lt "$(( limit * 1000 ))" ] || failed=1
      }

      ${lib.concatMapStringsSep "\n" (
        s: "check_sensor ${lib.escapeShellArg s.name} ${toString s.max}"
      ) sensors}

      exit "$failed"
    '';
}
