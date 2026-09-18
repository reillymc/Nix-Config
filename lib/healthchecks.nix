{
  lib,
  pkgs,
}:
rec {
  slugPattern = "[a-z0-9_-]+";

  isValidSlug = slug: builtins.match slugPattern slug != null;

  mkPingScript =
    {
      baseUrl,
      pingKeyFile,
      curl ? pkgs.curl,
    }:
    pkgs.writeShellScript "healthchecks-ping" ''
      set -eu

      if [ "$#" -lt 1 ]; then
        echo "usage: $0 <slug> [start|success|fail|log] [body-file]" >&2
        exit 2
      fi

      slug="$1"
      event="''${2:-success}"
      body="''${3:-}"

      case "$event" in
        start) suffix="/start" ;;
        success) suffix="" ;;
        fail) suffix="/fail" ;;
        log) suffix="/log" ;;
        *)
          echo "healthchecks-ping: unknown event '$event'" >&2
          exit 2
          ;;
      esac

      key="$(< ${lib.escapeShellArg pingKeyFile})"
      url="${lib.removeSuffix "/" baseUrl}/''${key}/''${slug}''${suffix}"

      if [ -n "$body" ]; then
        exec ${lib.getExe curl} \
          --fail \
          --silent \
          --show-error \
          --max-time 10 \
          --retry 3 \
          --data-binary "@$body" \
          "$url"
      else
        exec ${lib.getExe curl} \
          --fail \
          --silent \
          --show-error \
          --max-time 10 \
          --retry 3 \
          "$url"
      fi
    '';

  mkJournalPingScript =
    {
      pingScript,
      service,
      slug,
      event,
      scope ? "user",
      lines ? 200,
      maxBytes ? 100000,
      systemd ? pkgs.systemd,
    }:
    let
      unit = "${lib.removeSuffix ".service" service}.service";
      userFlag = lib.optionalString (scope == "user") "--user ";
    in
    pkgs.writeShellScript "healthchecks-journal-ping" ''
      set -eu

      tmp="$(mktemp)"
      trap 'rm -f "$tmp"' EXIT

      unit=${lib.escapeShellArg unit}

      capture() {
        local id
        id="$(${lib.getExe' systemd "systemctl"} ${userFlag}show -p InvocationID --value "$unit" 2>/dev/null || true)"
        if [ -n "$id" ]; then
          ${lib.getExe' systemd "journalctl"} ${userFlag}-u "$unit" "_SYSTEMD_INVOCATION_ID=$id" --no-pager --quiet -o cat
        else
          ${lib.getExe' systemd "journalctl"} ${userFlag}-u "$unit" -n ${toString lines} --no-pager --quiet -o cat
        fi
      }

      if capture 2>/dev/null | tail -c ${toString maxBytes} > "$tmp" && [ -s "$tmp" ]; then
        ${pingScript} ${lib.escapeShellArg slug} ${lib.escapeShellArg event} "$tmp"
      else
        ${pingScript} ${lib.escapeShellArg slug} ${lib.escapeShellArg event}
      fi
    '';

  mkCommandPingScript =
    {
      pingScript,
      slug,
      command,
      failureThreshold ? 1,
      maxBytes ? 100000,
      stateDir ? "/var/lib/healthchecks",
    }:
    pkgs.writeShellScript "healthchecks-command-ping" ''
      set -eu

      tmp="$(mktemp)"
      trap 'rm -f "$tmp"' EXIT

      state=${lib.escapeShellArg "${stateDir}/${slug}.state"}

      status=0
      if [ ${toString maxBytes} -gt 0 ]; then
        ${command} > "$tmp" 2>&1 || status=$?
        ${lib.getExe' pkgs.coreutils "tail"} -c ${toString maxBytes} "$tmp" > "$tmp.cut"
        ${lib.getExe' pkgs.coreutils "mv"} "$tmp.cut" "$tmp"
      else
        ${command} > /dev/null 2>&1 || status=$?
      fi

      send() {
        local event="$1"
        if [ ${toString maxBytes} -gt 0 ]; then
          ${pingScript} ${lib.escapeShellArg slug} "$event" "$tmp" || true
        else
          ${pingScript} ${lib.escapeShellArg slug} "$event" || true
        fi
      }

      if [ "$status" -eq 0 ]; then
        rm -f "$state"
        send success
        exit 0
      fi

      count=1
      if [ ${toString failureThreshold} -gt 1 ]; then
        if [ -f "$state" ]; then
          count=$(( $(${lib.getExe' pkgs.coreutils "cat"} "$state") + 1 ))
        fi
        printf '%s\n' "$count" > "$state"
      fi

      if [ "$count" -lt ${toString failureThreshold} ]; then
        echo "below failure threshold ($count/${toString failureThreshold})"
        send success
        exit 0
      fi

      send fail
      exit 0
    '';

  mkCommandUnits =
    {
      pingScript,
      slug,
      command,
      failureThreshold ? 1,
      maxBytes ? 100000,
      stateDir ? "/var/lib/healthchecks",
    }:
    {
      "healthchecks-${slug}" = {
        Unit.Description = "Healthchecks metric check for ${slug}";
        Service = {
          Type = "oneshot";
          StateDirectory = "healthchecks";
          ExecStart = toString (mkCommandPingScript {
            inherit
              pingScript
              slug
              command
              failureThreshold
              maxBytes
              stateDir
              ;
          });
        };
      };
    };

  mkUnits =
    {
      slug,
      startCommand,
      successCommand,
      failureCommand,
    }:
    {
      "healthchecks-${slug}-start" = {
        Unit.Description = "Healthchecks start ping for ${slug}";
        Service = {
          Type = "oneshot";
          ExecStart = "-${startCommand}";
        };
      };

      "healthchecks-${slug}-success" = {
        Unit.Description = "Healthchecks success ping for ${slug}";
        Service = {
          Type = "oneshot";
          ExecStart = "-${successCommand}";
        };
      };

      "healthchecks-${slug}-failure" = {
        Unit.Description = "Healthchecks failure ping for ${slug}";
        Service = {
          Type = "oneshot";
          ExecStart = "-${failureCommand}";
        };
      };
    };

  mkHooks =
    {
      slug,
      start ? true,
    }:
    {
      OnSuccess = [ "healthchecks-${slug}-success.service" ];
      OnFailure = [ "healthchecks-${slug}-failure.service" ];
    }
    // lib.optionalAttrs start {
      After = [ "healthchecks-${slug}-start.service" ];
      Wants = [ "healthchecks-${slug}-start.service" ];
    };
}
