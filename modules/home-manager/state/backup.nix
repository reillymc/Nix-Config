{
  config,
  lib,
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
        "--quiet"
      ];

      # Backblaze free egress is 3x stored/month; a random 3.33% of packs per
      # day reads ~1x/month (~64% of packs verified in 30 days, ~95% in 90)
      # and uses 33% of free egress relative to the repo size monthly.
      checkOpts = [
        "--read-data-subset=3.33%"
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
          After = [ "agenix.service" ];
          Wants = [ "agenix.service" ];
        };
        Service = {
          PrivateTmp = true;
          TimeoutStartSec = "1h";
        };
      };
    };
  };
}
