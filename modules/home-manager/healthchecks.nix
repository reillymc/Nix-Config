{
  config,
  lib,
  pkgs,
  mynixos,
  ...
}:
let
  cfg = config.myhome.healthchecks;

  healthchecks = import ../../lib/healthchecks.nix { inherit lib pkgs; };

  checkType = lib.types.submodule (
    { config, ... }:
    {
      options = {
        service = lib.mkOption {
          type = lib.types.str;
          example = "restic-backups-daily.service";
          description = ''
            Name of the systemd user service to hook. A `.service` suffix is
            optional.
          '';
        };

        slug = lib.mkOption {
          type = lib.types.str;
          default = config.service;
          defaultText = lib.literalExpression "config.service";
          example = "restic-backups-daily";
          description = ''
            Healthchecks slug for this check, before `slugPrefix` is applied.
          '';
        };

        start = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Send a `/start` ping before the service runs so Healthchecks can
            measure the run duration.
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
            Attach the service's systemd journal output to its pings. `null`
            disables logging; the default attaches the failed invocation's log.
            Journal output can contain sensitive data.
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

  normalize =
    e:
    let
      entry =
        if lib.isString e then
          {
            service = e;
            slug = e;
            start = true;
            logs = { };
          }
        else
          e;
      service = lib.removeSuffix ".service" entry.service;
    in
    {
      inherit service;
      slug = lib.optionalString (cfg.slugPrefix != "") "${cfg.slugPrefix}-" + entry.slug;
      start = entry.start;
      logs = normalizeLogs entry.logs;
    };

  checks = map normalize cfg.checks;

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
            scope = "user";
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
in
{
  options.myhome.healthchecks = {
    enable = (lib.mkEnableOption "Healthchecks pings for systemd user services") // {
      description = ''
        Whether to enable Healthchecks pings for systemd user services.
        Defaults to `mynixos.healthchecks.enable` when Home Manager runs as a
        NixOS module.
      '';
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://healthchecks.homelab.reillymc.com/ping";
      description = ''
        Base ping URL, without the project ping key or slug. Endpoints are
        derived as `<baseUrl>/<pingKey>/<slug>[/start|/fail]`.

        Defaults to `mynixos.healthchecks.baseUrl` when Home Manager runs as a
        NixOS module.
      '';
    };

    pingKeyFile = lib.mkOption {
      type = lib.types.str;
      example = "/run/agenix/healthchecks/ping-key";
      description = ''
        Runtime path to the age-decrypted project ping key. The key is read at
        ping time and never embedded in the Nix store or unit files.

        Defaults to `mynixos.healthchecks.pingKeyFile` when Home Manager runs
        as a NixOS module.
      '';
    };

    slugPrefix = lib.mkOption {
      type = lib.types.str;
      default = config.home.username;
      defaultText = lib.literalExpression "config.home.username";
      description = ''
        Prefix prepended (with a hyphen) to every slug. Namespaces checks when
        several users share one Healthchecks project, since slugs must be
        unique within a project.
      '';
    };

    checks = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str checkType);
      default = [ ];
      example = lib.literalExpression ''[ "restic-backups-daily" ]'';
      description = ''
        Systemd user services to hook up to Healthchecks. Each entry is either
        a service name (also used as the slug) or an attribute set accepting
        `service`, `slug`, `start`, and `logs`.
      '';
    };
  };

  config = lib.mkMerge [
    {
      myhome.healthchecks.enable = lib.mkDefault ((mynixos.healthchecks or { }).enable or false);
      myhome.healthchecks.baseUrl = lib.mkDefault ((mynixos.healthchecks or { }).baseUrl or "");
      myhome.healthchecks.pingKeyFile = lib.mkDefault ((mynixos.healthchecks or { }).pingKeyFile or "");
    }

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = checks == [ ] || (cfg.baseUrl != "" && cfg.pingKeyFile != "");
          message = "myhome.healthchecks: set `baseUrl` and `pingKeyFile` before registering checks.";
        }
        {
          assertion = cfg.baseUrl == "" || builtins.match "https?://.+" cfg.baseUrl != null;
          message = "myhome.healthchecks.baseUrl must be an http(s) URL.";
        }
        {
          assertion = lib.all (c: healthchecks.isValidSlug c.slug) checks;
          message = "myhome.healthchecks: check slugs must match '${healthchecks.slugPattern}'.";
        }
        {
          assertion = lib.length (lib.unique (map (c: c.slug) checks)) == lib.length checks;
          message = "myhome.healthchecks: check slugs must be unique.";
        }
        {
          assertion = lib.all (c: builtins.hasAttr c.service config.systemd.user.services) checks;
          message = "myhome.healthchecks: every check's `service` must be a defined systemd user service.";
        }
        {
          assertion = lib.all (c: c.logs == null || c.logs.events != [ ]) checks;
          message = "myhome.healthchecks: `logs.events` must not be empty; use `logs = null` to disable logging.";
        }
        {
          assertion = lib.all (c: c.logs == null || c.logs.maxBytes <= 100000) checks;
          message = "myhome.healthchecks: `logs.maxBytes` must not exceed 100000 (Healthchecks stores the first 100 kB).";
        }
      ];

      systemd.user.services = lib.mkIf (checks != [ ]) (
        lib.mkMerge (
          lib.concatMap (c: [
            (healthchecks.mkUnits (mkCommands c))
            {
              ${c.service}.Unit = healthchecks.mkHooks { inherit (c) slug start; };
            }
          ]) checks
        )
      );
    })
  ];
}
