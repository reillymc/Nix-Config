{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myhome.notify;

  notify = import ../../lib/notify.nix { inherit lib pkgs; };

  eventType = lib.types.submodule {
    options = {
      title = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Notification title; defaults to `<service> failed` or
          `<service> succeeded`.
        '';
      };

      body = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional notification body.";
      };

      urgency = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "low"
            "normal"
            "critical"
          ]
        );
        default = null;
        description = ''
          Notification urgency; defaults to `critical` for failures and `low`
          for successes.
        '';
      };

      appName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Application name shown by the notification daemon; defaults to `systemd`.";
      };

      icon = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional icon name or path.";
      };
    };
  };

  checkType = lib.types.submodule {
    options = {
      service = lib.mkOption {
        type = lib.types.str;
        example = "restic-backups-daily.service";
        description = ''
          Name of the systemd user service to notify about. A `.service` suffix
          is optional.
        '';
      };

      failure = lib.mkOption {
        type = lib.types.nullOr eventType;
        default = { };
        description = "Failure notification. `null` disables it.";
      };

      success = lib.mkOption {
        type = lib.types.nullOr eventType;
        default = null;
        description = "Success notification. Disabled by default.";
      };
    };
  };

  normalizeEvent =
    kind: service: ev:
    if ev == null then
      null
    else
      {
        title =
          if (ev.title or null) != null then
            ev.title
          else
            "${service} ${if kind == "failure" then "failed" else "succeeded"}";
        body = ev.body or null;
        urgency =
          if (ev.urgency or null) != null then
            ev.urgency
          else
            (if kind == "failure" then "critical" else "low");
        appName = if (ev.appName or null) != null then ev.appName else "systemd";
        icon = ev.icon or null;
      };

  normalize =
    e:
    let
      entry = if lib.isString e then { service = e; } else e;
      service = lib.removeSuffix ".service" entry.service;
    in
    {
      inherit service;
      failure = normalizeEvent "failure" service (entry.failure or { });
      success = normalizeEvent "success" service (entry.success or null);
    };

  services = map normalize cfg.services;

  mkUnit = service: kind: ev: {
    "notify-${notify.sanitizeName service}-${kind}" = {
      Unit.Description = "Desktop notification for ${service} ${kind}";
      Service = {
        Type = "oneshot";
        Environment = [ "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus" ];
        ExecStart = "-${notify.mkNotifyCommand ev}";
      };
    };
  };
in
{
  options.myhome.notify = {
    enable = lib.mkEnableOption "desktop notifications for systemd user services";

    services = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str checkType);
      default = [ ];
      example = lib.literalExpression ''[ "restic-backups-daily" ]'';
      description = ''
        Systemd user services to show desktop notifications for. Each entry is
        either a service name (notified on failure) or an attribute set
        accepting `service`, `failure`, and `success`.
      '';
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.services == [ ] || cfg.enable;
          message = "myhome.notify: `services` is set but `myhome.notify.enable` is false.";
        }
      ];
    }

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = lib.all (s: s.failure != null || s.success != null) services;
          message = "myhome.notify: every entry must enable at least one of `failure` or `success`.";
        }
        {
          assertion = lib.all (s: builtins.hasAttr s.service config.systemd.user.services) services;
          message = "myhome.notify: every entry's `service` must be a defined systemd user service.";
        }
      ];

      systemd.user.services = lib.mkIf (services != [ ]) (
        lib.mkMerge (
          lib.concatMap (
            s:
            lib.optional (s.failure != null) (mkUnit s.service "failure" s.failure)
            ++ lib.optional (s.success != null) (mkUnit s.service "success" s.success)
            ++ [
              {
                ${s.service}.Unit = notify.mkHooks { inherit (s) service failure success; };
              }
            ]
          ) services
        )
      );
    })
  ];
}
