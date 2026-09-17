{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myhome.state.backup;

  home = config.home.homeDirectory;
  state = config.myhome.state;

  marked = lib.filter (e: lib.isString e || e.backup.enable) (state.directories ++ state.files);

  statePath = e: if lib.isString e then e else (e.directory or e.file);

  toAbsolute = p: if lib.hasPrefix "/" p then p else "${home}/${p}";

  backupPaths = lib.unique (map toAbsolute (map statePath marked));

  startPing = lib.optional (cfg.notify.startUrl != null) "notify-start-restic-backups-daily.service";
in
{
  options.myhome.state.backup = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable restic backups of `myhome.state' entries.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Options forwarded verbatim to `services.restic.backups.daily' (e.g.
        `repositoryFile', `passwordFile', `environmentFile', `repository',
        `passwordCommand'). Baked defaults (`initialize', `pruneOpts',
        `checkOpts', `timerConfig', `exclude') are overridden by keys set here.
        `paths' is derived from `myhome.state' and is always forced.
      '';
    };

    notify = {
      startUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          URL pinged before the backup starts (e.g. healthchecks `/start').
          Lets healthchecks measure the run duration.
        '';
      };

      successUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL pinged after a successful backup (e.g. healthchecks).";
      };

      failureUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL pinged after a failed backup (e.g. healthchecks `/fail').";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = backupPaths != [ ];
        message = ''
          myhome.state.backup is enabled but there is nothing to back up.
          Every state entry is backed up unless `backup.enable = false'.
        '';
      }
    ];

    services.restic.enable = true;

    services.restic.backups.daily = {
      initialize = true;

      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 20"
      ];

      checkOpts = [
        "--read-data-subset=5G"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 08:00:00";
        Persistent = true;
      };

      exclude = [
        "${home}/Projects/**/node_modules"
        "${home}/Projects/**/.expo"
        "${home}/Projects/**/.svelte-kit"
        "${home}/Projects/**/dist"
        "${home}/Projects/**/lib"
        "${home}/Projects/**/bin"
        "${home}/Projects/**/target"
        "${home}/Projects/**/logs"
        "${home}/.local/share/Steam/steamapps/compatdata/*/pfx/drive_c/windows"
        "${home}/.local/share/Steam/steamapps/compatdata/*/pfx/drive_c/ProgramData"
      ];
    }
    // cfg.settings
    // {
      paths = backupPaths;
    };

    systemd.user.services = {
      "restic-backups-daily" = {
        Unit = {
          After = [ "agenix.service" ] ++ startPing;
          Wants = [ "agenix.service" ] ++ startPing;
          OnFailure = [ "notify-failed-restic-backups-daily.service" ];
          OnSuccess = [ "notify-success-restic-backups-daily.service" ];
        };
        Service = {
          PrivateTmp = true;
          TimeoutStartSec = "1h";
        };
      };

      "notify-start-restic-backups-daily" = lib.mkIf (cfg.notify.startUrl != null) {
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.curl}/bin/curl --fail --silent --show-error --max-time 10 ${lib.escapeShellArg cfg.notify.startUrl}";
        };
      };

      "notify-failed-restic-backups-daily" = {
        Service = {
          Type = "oneshot";
          Environment = [ "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus" ];
          ExecStart = [
            "-${pkgs.libnotify}/bin/notify-send --app-name=restic --urgency=critical \"Backup failed\""
          ]
          ++
            lib.optional (cfg.notify.failureUrl != null)
              "${pkgs.curl}/bin/curl --fail --silent --show-error --max-time 10 ${lib.escapeShellArg cfg.notify.failureUrl}";
        };
      };

      "notify-success-restic-backups-daily" = {
        Service = {
          Type = "oneshot";
          Environment = [ "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus" ];
          ExecStart = [
            "-${pkgs.libnotify}/bin/notify-send --app-name=restic --urgency=low \"Backup complete\""
          ]
          ++
            lib.optional (cfg.notify.successUrl != null)
              "${pkgs.curl}/bin/curl --fail --silent --show-error --max-time 10 ${lib.escapeShellArg cfg.notify.successUrl}";
        };
      };
    };
  };
}
