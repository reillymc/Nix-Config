{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mynixos.healthchecks;

  healthchecks = import ../../lib/healthchecks.nix { inherit lib pkgs; };

  checkType = lib.types.submodule (
    { config, ... }:
    {
      options = {
        service = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "nix-gc.service";
          description = ''
            Name of the systemd service to hook. A `.service` suffix is
            optional. Mutually exclusive with `command`.
          '';
        };

        command = lib.mkOption {
          type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
          default = null;
          example = lib.literalExpression "pkgs.writeShellScript \"...\" ''...''";
          description = ''
            Command run periodically by a generated systemd timer. Exit status
            0 pings success, non-zero pings failure. Its output is attached to
            the ping. Mutually exclusive with `service`.
          '';
        };

        slug = lib.mkOption {
          type = lib.types.str;
          default = if config.service != null then config.service else "";
          defaultText = lib.literalExpression "config.service";
          example = "disk";
          description = ''
            Healthchecks slug for this check, before `slugPrefix` is applied.
            Required for `command` checks.
          '';
        };

        start = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Send a `/start` ping before the service runs so Healthchecks can
            measure the run duration. Ignored for `command` checks.
          '';
        };

        logs = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                events = lib.mkOption {
                  type = lib.types.listOf (
                    lib.types.enum [
                      "success"
                      "failure"
                    ]
                  );
                  default = [ "failure" ];
                  description = "Events that attach the service's journal output.";
                };

                lines = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 200;
                  description = ''
                    Journal lines captured when the unit's invocation id is
                    unavailable.
                  '';
                };

                maxBytes = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 100000;
                  description = ''
                    Maximum number of log bytes attached. Healthchecks stores
                    the first 100000 bytes of a request body.
                  '';
                };
              };
            }
          );
          default = { };
          description = ''
            Attach output to the pings. For service checks this is the failed
            invocation's journal; for `command` checks it is the command
            output, sent on success and failure. `null` disables it.  Output
            can contain sensitive data.
          '';
        };

        timer = lib.mkOption {
          type = lib.types.str;
          default = "*-*-* *:0/15:00";
          example = "*-*-* *:0/05:00";
          description = "OnCalendar schedule for `command` checks.";
        };

        failureThreshold = lib.mkOption {
          type = lib.types.ints.positive;
          default = 1;
          description = ''
            Consecutive non-zero exits required before pinging failure.
            Ignored for service checks.
          '';
        };
      };
    }
  );

  normalizeLogs =
    logs:
    if logs == null then
      null
    else
      {
        events = logs.events or [ "failure" ];
        lines = logs.lines or 200;
        maxBytes = logs.maxBytes or 100000;
      };

  prefixSlug = slug: lib.optionalString (cfg.slugPrefix != "") "${cfg.slugPrefix}-" + slug;

  normalize =
    e:
    if lib.isString e then
      let
        service = lib.removeSuffix ".service" e;
      in
      {
        inherit service;
        kind = "service";
        slug = prefixSlug e;
        start = true;
        logs = normalizeLogs { };
        command = null;
        timer = "*-*-* *:0/15:00";
        failureThreshold = 1;
      }
    else
      {
        service = if e.service != null then lib.removeSuffix ".service" e.service else null;
        kind = if e.command != null then "command" else "service";
        slug = prefixSlug e.slug;
        inherit (e)
          start
          command
          timer
          failureThreshold
          ;
        logs = normalizeLogs e.logs;
      };

  checks = map normalize cfg.checks;

  commandChecks = lib.filter (c: c.kind == "command") checks;
  serviceChecks = lib.filter (c: c.kind == "service") checks;

  ping = healthchecks.mkPingScript {
    inherit (cfg) baseUrl pingKeyFile;
  };

  mkCommands =
    c:
    let
      plain = event: "${ping} ${lib.escapeShellArg c.slug} ${event}";

      logged =
        event:
        toString (
          healthchecks.mkJournalPingScript {
            pingScript = ping;
            inherit (c) service slug;
            inherit event;
            scope = "system";
            inherit (c.logs) lines maxBytes;
          }
        );

      eventCommand =
        kind:
        let
          event = if kind == "failure" then "fail" else "success";
        in
        if c.logs != null && lib.elem kind c.logs.events then logged event else plain event;
    in
    {
      inherit (c) slug;
      startCommand = plain "start";
      successCommand = eventCommand "success";
      failureCommand = eventCommand "failure";
    };

  toUnits =
    attr:
    lib.mapAttrs (name: unit: {
      unitConfig = unit.Unit;
      serviceConfig = unit.Service;
    }) attr;
in
{
  options.mynixos.healthchecks = {
    enable = lib.mkEnableOption "Healthchecks pings for systemd services";

    baseUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://healthchecks.homelab.reillymc.com/ping";
      description = ''
        Base ping URL, without the project ping key or slug. Endpoints are
        derived as `<baseUrl>/<pingKey>/<slug>[/start|/fail]`.
      '';
    };

    pingKeyFile = lib.mkOption {
      type = lib.types.str;
      example = "/run/agenix/healthchecks/ping-key";
      description = ''
        Runtime path to the age-decrypted project ping key. The key is read at
        ping time and never embedded in the Nix store or unit files.
      '';
    };

    slugPrefix = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Prefix prepended (with a hyphen) to every slug. System checks are
        host-wide and usually need no prefix; user checks use their username as
        prefix, so slugs stay unique within a project.
      '';
    };

    checks = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str checkType);
      default = [ ];
      example = lib.literalExpression ''[ "nix-gc" ]'';
      description = ''
        Services and commands to report to Healthchecks. Each entry is either a
        service name (also used as the slug) or an attribute set accepting
        `service` or `command`, `slug`, `start`, `logs`, `timer`, and
        `failureThreshold`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = checks == [ ] || (cfg.baseUrl != "" && cfg.pingKeyFile != "");
        message = "mynixos.healthchecks: set `baseUrl` and `pingKeyFile` before registering checks.";
      }
      {
        assertion = cfg.baseUrl == "" || builtins.match "https?://.+" cfg.baseUrl != null;
        message = "mynixos.healthchecks.baseUrl must be an http(s) URL.";
      }
      {
        assertion = lib.all (c: (c.service != null) != (c.command != null)) checks;
        message = "mynixos.healthchecks: each check needs exactly one of `service` or `command`.";
      }
      {
        assertion = lib.all (c: c.slug != "") checks;
        message = "mynixos.healthchecks: each check needs a `slug`.";
      }
      {
        assertion = lib.all (c: healthchecks.isValidSlug c.slug) checks;
        message = "mynixos.healthchecks: check slugs must match '${healthchecks.slugPattern}'.";
      }
      {
        assertion = lib.length (lib.unique (map (c: c.slug) checks)) == lib.length checks;
        message = "mynixos.healthchecks: check slugs must be unique.";
      }
      {
        assertion = lib.all (
          c: c.kind == "command" || builtins.hasAttr c.service config.systemd.services
        ) serviceChecks;
        message = "mynixos.healthchecks: every service check's `service` must be a defined systemd service.";
      }
      {
        assertion = lib.all (c: c.logs == null || c.logs.events != [ ]) checks;
        message = "mynixos.healthchecks: `logs.events` must not be empty; use `logs = null` to disable logging.";
      }
      {
        assertion = lib.all (c: c.logs == null || c.logs.maxBytes <= 100000) checks;
        message = "mynixos.healthchecks: `logs.maxBytes` must not exceed 100000 (Healthchecks stores the first 100 kB).";
      }
    ];

    systemd.services = lib.mkIf (checks != [ ]) (
      lib.mkMerge (
        lib.concatMap (
          c:
          if c.kind == "command" then
            [
              (toUnits (
                healthchecks.mkCommandUnits {
                  pingScript = ping;
                  inherit (c) slug command failureThreshold;
                  maxBytes = if c.logs == null then 0 else c.logs.maxBytes;
                }
              ))
            ]
          else
            [
              (toUnits (healthchecks.mkUnits (mkCommands c)))
              {
                ${c.service}.unitConfig = healthchecks.mkHooks { inherit (c) slug start; };
              }
            ]
        ) checks
      )
    );

    systemd.timers = lib.mkIf (commandChecks != [ ]) (
      lib.mkMerge (
        map (c: {
          "healthchecks-${c.slug}" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = c.timer;
              Persistent = true;
              RandomizedDelaySec = "1m";
            };
          };
        }) commandChecks
      )
    );
  };
}
