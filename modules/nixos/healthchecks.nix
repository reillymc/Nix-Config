{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mynixos.healthchecks;

  healthchecks = import ../../lib/healthchecks.nix { inherit lib pkgs; };

  # For an even 15 min healthchecks period, including RandomizedDelaySec = "30s";
  defaultTimer = "*-*-* *:0/14:00";

  checkType = lib.types.submodule (
    { config, ... }:
    {
      options = {
        service = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "nix-gc";
          description = ''
            Name of the systemd service to hook, without the `.service`
            suffix. Mutually exclusive with `command`.
          '';
        };

        command = lib.mkOption {
          type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
          default = null;
          example = lib.literalExpression "pkgs.writeShellScript \"...\" ''...''";
          description = ''
            Command run periodically by a generated systemd timer. Exit status
            0 pings success, non-zero pings failure. Mutually exclusive with
            `service`.
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

        timer = lib.mkOption {
          type = lib.types.str;
          default = defaultTimer;
          example = "*-*-* *:0/05:00";
          description = "OnCalendar schedule for `command` checks.";
        };
      };
    }
  );

  prefixSlug = slug: (lib.optionalString (cfg.slugPrefix != "") "${cfg.slugPrefix}-") + slug;

  normalize =
    e:
    if lib.isString e then
      {
        kind = "service";
        service = e;
        command = null;
        slug = prefixSlug e;
      }
    else
      {
        inherit (e)
          service
          command
          timer
          ;
        kind = if e.command != null then "command" else "service";
        slug = prefixSlug e.slug;
      };

  checks = map normalize cfg.checks;

  commandChecks = lib.filter (c: c.kind == "command") checks;

  ping = healthchecks.mkPingScript {
    inherit (cfg) baseUrl pingKeyFile;
  };

  mkCommands =
    c:
    healthchecks.mkServiceCommands {
      pingScript = ping;
      scope = "system";
      check = c;
    };

  toUnits =
    attr:
    lib.mapAttrs (_: unit: {
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
        service name without the `.service` suffix (also used as the slug) or an
        attribute set accepting `service` or `command`, `slug`, and `timer`.
        Service checks ping start, success, and failure, attaching the
        invocation's journal output; command checks attach their output.
      '';
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.checks == [ ] || cfg.enable;
          message = "mynixos.healthchecks: `checks` is set but `mynixos.healthchecks.enable` is false.";
        }
      ];
    }

    (lib.mkIf cfg.enable {
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
          ) checks;
          message = "mynixos.healthchecks: every service check's `service` must be a defined systemd service.";
        }
      ];

      systemd.services = lib.mkMerge (
        lib.concatMap (
          c:
          if c.kind == "command" then
            [
              (toUnits (
                healthchecks.mkCommandUnits {
                  pingScript = ping;
                  inherit (c) slug command;
                }
              ))
            ]
          else
            [
              (toUnits (healthchecks.mkUnits (mkCommands c)))
              {
                ${c.service}.unitConfig = healthchecks.mkHooks { inherit (c) slug; };
              }
            ]
        ) checks
      );

      systemd.timers = lib.mkMerge (
        map (c: {
          "healthchecks-${c.slug}" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = c.timer;
              Persistent = true;
              RandomizedDelaySec = "30s";
            };
          };
        }) commandChecks
      );
    })
  ];
}
