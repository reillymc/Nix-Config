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
          example = "restic-backups-daily";
          description = ''
            Name of the systemd user service to hook, without the `.service`
            suffix.
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
      };
    }
  );

  normalize =
    e:
    let
      entry =
        if lib.isString e then
          {
            service = e;
            slug = e;
          }
        else
          e;
      service = entry.service;
    in
    {
      inherit service;
      slug = (lib.optionalString (cfg.slugPrefix != "") "${cfg.slugPrefix}-") + entry.slug;
    };

  checks = map normalize cfg.checks;

  ping = healthchecks.mkPingScript {
    inherit (cfg) baseUrl pingKeyFile;
  };

  mkCommands =
    c:
    healthchecks.mkServiceCommands {
      pingScript = ping;
      scope = "user";
      check = c;
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
        a service name without the `.service` suffix (also used as the slug) or
        an attribute set accepting `service` and `slug`. Checks ping start,
        success, and failure, attaching the invocation's journal output.
      '';
    };
  };

  config = lib.mkMerge [
    {
      myhome.healthchecks.enable = lib.mkDefault ((mynixos.healthchecks or { }).enable or false);
      myhome.healthchecks.baseUrl = lib.mkDefault ((mynixos.healthchecks or { }).baseUrl or "");
      myhome.healthchecks.pingKeyFile = lib.mkDefault ((mynixos.healthchecks or { }).pingKeyFile or "");

      assertions = [
        {
          assertion = cfg.checks == [ ] || cfg.enable;
          message = "myhome.healthchecks: `checks` is set but `myhome.healthchecks.enable` is false.";
        }
      ];
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
      ];

      systemd.user.services = lib.mkMerge (
        lib.concatMap (c: [
          (healthchecks.mkUnits (mkCommands c))
          {
            ${c.service}.Unit = healthchecks.mkHooks { inherit (c) slug; };
          }
        ]) checks
      );
    })
  ];
}
