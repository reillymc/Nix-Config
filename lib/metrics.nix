{
  lib,
  pkgs,
}:
let
  util-linux = pkgs.util-linux;
  systemd = pkgs.systemd;
  coreutils = pkgs.coreutils;
  gawk = pkgs.gawk;
  gnugrep = pkgs.gnugrep;
in
{
  disk =
    {
      maxPercent ? 80,
    }:
    pkgs.writeShellScript "metric-disk" ''
      set -eu

      failed=0
      printed=0

      mounts_on_disk() {
        local disk="$1"
        local devices dev
        devices="$(${lib.getExe' util-linux "lsblk"} -lno NAME "$disk")"
        ${lib.getExe' util-linux "findmnt"} --real -rno TARGET,SOURCE,FSROOT,USE% | while read -r target source fsroot use; do
          dev="$(${lib.getExe' coreutils "basename"} "$source")"
          printf '%s\n' "$devices" | ${lib.getExe' gnugrep "grep"} -qxF "$dev" || continue
          [ "$fsroot" = "/" ] || continue
          printf '%s %s (%s)\n' "$target" "$use" "$dev"
        done
      }

      report_disk() {
        local disk="$1"
        local breakdown size used percent

        breakdown="$(mounts_on_disk "$disk")"

        if [ -z "$breakdown" ]; then
          return 0
        fi

        size="$(${lib.getExe' util-linux "lsblk"} -bdno SIZE "$disk")"
        used="$(${lib.getExe' util-linux "lsblk"} -bno FSUSED "$disk" | ${lib.getExe' gawk "awk"} '{ sum += $1 } END { print sum + 0 }')"

        if [ "$size" -le 0 ]; then
          echo "could not determine disk size for $disk"
          failed=1
          return 0
        fi

        percent=$(( used * 100 / size ))
        echo "$(${lib.getExe' coreutils "basename"} "$disk") (whole disk): ''${percent}% used ($((used / 1073741824))G/$((size / 1073741824))G)"

        printf '%s\n' "$breakdown" | ${lib.getExe' gawk "awk"} '{ print "  " $0 }'

        printed=$(( printed + 1 ))
        [ "$percent" -lt ${toString maxPercent} ] || failed=1
      }

      for name in $(${lib.getExe' util-linux "lsblk"} -dno NAME,TYPE | ${lib.getExe' gawk "awk"} '$2 == "disk" { print $1 }' | ${lib.getExe' gnugrep "grep"} -vE '^(zram|loop|ram)' || true); do
        report_disk "/dev/$name"
      done

      if [ "$printed" -eq 0 ]; then
        echo "no mounted disks found"
      fi

      exit "$failed"
    '';

  failedUnits =
    {
      allow ? [ ],
    }:
    pkgs.writeShellScript "metric-failed-units" ''
      set -eu

      failed="$(${lib.getExe' systemd "systemctl"} --failed --no-legend --plain --no-pager 2>/dev/null | ${lib.getExe' gawk "awk"} '{ print $1 }')"

      remaining=""
      for unit in $failed; do
        ${
          if allow == [ ] then
            ''remaining="$remaining $unit"''
          else
            ''
              case "$unit" in
                        ${lib.concatStringsSep "|" allow}) continue ;;
                        *) remaining="$remaining $unit" ;;
                      esac''
        }
      done

      if [ -n "$remaining" ]; then
        echo "failed units:''${remaining}"
        exit 1
      fi

      echo "no failed units"
    '';

  temperature =
    {
      max,
      names ? [ ],
      sysfs ? "/sys/class/hwmon",
    }:
    pkgs.writeShellScript "metric-temperature" ''
      set -eu

      peak=0
      peak_sensor=""

      for f in ${sysfs}/hwmon*/temp*_input; do
        [ -r "$f" ] || continue

        name="$(${lib.getExe' coreutils "cat"} "''${f%/temp*_input}/name" 2>/dev/null || echo unknown)"

        ${lib.optionalString (names != [ ]) ''
          case "$name" in
            ${lib.concatStringsSep "|" names}) ;;
            *) continue ;;
          esac
        ''}

        label="$(${lib.getExe' coreutils "cat"} "''${f%_input}_label" 2>/dev/null || true)"
        if [ -n "$label" ]; then
          sensor="$name $label"
        else
          sensor="$name $(${lib.getExe' coreutils "basename"} "''${f%_input}")"
        fi

        value="$(${lib.getExe' coreutils "cat"} "$f")"
        [ "$value" -gt 0 ] || continue

        echo "$sensor: $((value / 1000))C"

        if [ "$value" -gt "$peak" ]; then
          peak="$value"
          peak_sensor="$sensor"
        fi
      done

      if [ "$peak" -eq 0 ]; then
        echo "no readable temperature sensors"
        exit 1
      fi

      echo "peak: $((peak / 1000))C ($peak_sensor)"
      [ "$peak" -lt ${toString (max * 1000)} ]
    '';
}
