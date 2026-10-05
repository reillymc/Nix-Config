{
  lib,
  pkgs,
}:
rec {
  hooks = import ./systemd-hooks.nix { inherit lib; };

  slugPattern = "[a-z0-9_-]+";

  isValidSlug = slug: builtins.match slugPattern slug != null;

  logMaxBytes = 100000;

  logMaxLines = 200;

  mkPingScript =
    {
      baseUrl,
      pingKeyFile,
    }:
    pkgs.writeShellScript "healthchecks-ping" ''
      set -eu

      slug="$1"
      event="''${2:-success}"
      body="''${3:-}"

      case "$event" in
        start) suffix="/start" ;;
        success) suffix="" ;;
        fail) suffix="/fail" ;;
        *)
          echo "healthchecks-ping: unknown event '$event'" >&2
          exit 2
          ;;
      esac

      key="$(< ${lib.escapeShellArg pingKeyFile})"
      url=${lib.escapeShellArg (lib.removeSuffix "/" baseUrl)}"/''${key}/''${slug}''${suffix}"

      # The ping key is part of the URL and is a project-wide secret; hand the
      # URL to curl through a config on stdin so it stays out of the process
      # list.
      escaped=''${url//\\/\\\\}
      escaped=''${escaped//\"/\\\"}

      curl_args=(
        --fail
        --silent
        --show-error
        --connect-timeout 5
        --max-time 15
        --retry-delay 5
        --retry-connrefused
      )
      # Start pings are ordered before the hooked service: bound their total
      # retry window so an unreachable Healthchecks cannot stop the service.
      if [ "$event" = "start" ]; then
        curl_args+=( --retry 5 --retry-max-time 45 )
      else
        curl_args+=( --retry 8 --retry-max-time 240 )
      fi
      if [ -n "$body" ]; then
        curl_args+=( --data-binary "@$body" )
      fi

      printf 'url = "%s"\n' "$escaped" | ${lib.getExe pkgs.curl} --config - "''${curl_args[@]}"
    '';

  mkJournalPingScript =
    {
      pingScript,
      service,
      slug,
      event,
      scope ? "user",
    }:
    let
      unit = lib.escapeShellArg "${service}.service";
      userFlag = lib.optionalString (scope == "user") "--user ";
    in
    pkgs.writeShellScript "healthchecks-journal-ping" ''
      set -eu

      tmp="$(${lib.getExe' pkgs.coreutils "mktemp"} --tmpdir healthchecks-journal.XXXXXX)"
      trap '${lib.getExe' pkgs.coreutils "rm"} -f "$tmp"' EXIT

      capture() {
        local id
        id="$(${lib.getExe' pkgs.systemd "systemctl"} ${userFlag}show -p InvocationID --value ${unit} 2>/dev/null || true)"
        if [ -n "$id" ]; then
          ${lib.getExe' pkgs.systemd "journalctl"} ${userFlag}-u ${unit} "_SYSTEMD_INVOCATION_ID=$id" --no-pager --quiet -o cat
        else
          ${lib.getExe' pkgs.systemd "journalctl"} ${userFlag}-u ${unit} -n ${toString logMaxLines} --no-pager --quiet -o cat
        fi
      }

      if capture 2>/dev/null | ${lib.getExe' pkgs.coreutils "tail"} -c ${toString logMaxBytes} > "$tmp" && [ -s "$tmp" ]; then
        ${pingScript} ${lib.escapeShellArg slug} ${lib.escapeShellArg event} "$tmp"
      else
        ${pingScript} ${lib.escapeShellArg slug} ${lib.escapeShellArg event}
      fi
    '';

  mkServiceCommands =
    {
      pingScript,
      scope,
      check,
    }:
    let
      journal =
        event:
        toString (mkJournalPingScript {
          inherit pingScript scope event;
          inherit (check) service slug;
        });
    in
    {
      inherit (check) slug;
      startCommand = "${pingScript} ${lib.escapeShellArg check.slug} start";
      successCommand = journal "success";
      failureCommand = journal "fail";
    };

  mkCommandPingScript =
    {
      pingScript,
      slug,
      command,
    }:
    pkgs.writeShellScript "healthchecks-command-ping" ''
      set -eu

      tmp="$(${lib.getExe' pkgs.coreutils "mktemp"} --tmpdir healthchecks-command.XXXXXX)"
      trap '${lib.getExe' pkgs.coreutils "rm"} -f "$tmp"' EXIT

      status=0
      ${command} > "$tmp" 2>&1 || status=$?

      ${lib.getExe' pkgs.coreutils "tail"} -c ${toString logMaxBytes} "$tmp" > "$tmp.cut"
      ${lib.getExe' pkgs.coreutils "mv"} "$tmp.cut" "$tmp"

      send() {
        local event="$1"
        if [ -s "$tmp" ]; then
          ${pingScript} ${lib.escapeShellArg slug} "$event" "$tmp" || true
        else
          ${pingScript} ${lib.escapeShellArg slug} "$event" || true
        fi
      }

      if [ "$status" -eq 0 ]; then
        send success
      else
        send fail
      fi
    '';

  mkCommandUnits =
    {
      pingScript,
      slug,
      command,
    }:
    {
      "healthchecks-${slug}" = {
        Unit.Description = "Healthchecks check for ${slug}";
        Service = {
          Type = "oneshot";
          ExecStart = toString (mkCommandPingScript {
            inherit pingScript slug command;
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
    { slug }:
    hooks {
      prefix = "healthchecks";
      name = slug;
      start = true;
    };
}
