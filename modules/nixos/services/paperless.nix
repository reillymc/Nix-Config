{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mynixos.services.paperless;
  port = 28981;

  paperless-bkp-script-unwrapped = pkgs.writeShellScriptBin "paperless-bkp-script" ''
    set -e

    # ${pkgs.coreutils}/bin/rm -rf ${cfg.backupDir} # Attempt to prevent rclone copying new file after each backup
    ${pkgs.coreutils}/bin/cp -r /var/lib/paperless/export ${cfg.backupDir}
    ${pkgs.coreutils}/bin/chown -R reilly:users ${cfg.backupDir}
    echo "Backup complete"
  '';

  paperless-bkp-script = pkgs.symlinkJoin {
    name = "paperless-bkp-script-with-deps";
    paths = [
      paperless-bkp-script-unwrapped
      pkgs.gnutar
      pkgs.gzip
    ];
  };
in
{
  options.mynixos.services.paperless = {
    enable = lib.mkEnableOption "Enable Paperless";

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backup/paperless";
      example = "/srv/backup/paperless";
      description = ''
        Directory to back up Paperless data to.
      '';
    };

    openPort = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open the firewall port (28981) for the Paperless web interface.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      exporter = {
        enable = true;
        onCalendar = "17:30:00";
      };
      port = port;
    }
    // lib.optionalAttrs cfg.openPort {
      address = "0.0.0.0";
    };

    systemd.services."paperless-user-backup" = {
      description = "Paperless backup handler";
      serviceConfig = {
        ExecStart = "${paperless-bkp-script}/bin/paperless-bkp-script";
        Type = "oneshot";
        User = "root";
        Environment = "PATH=${paperless-bkp-script}/bin";
      };
    };

    systemd.timers."paperless-user-backup" = {
      description = "Timer to run paperless backup handler";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 17:35:00";
        Persistent = true;
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPortRanges = lib.mkIf cfg.openPort [
      {
        from = port;
        to = port;
      }
    ];
  };
}
