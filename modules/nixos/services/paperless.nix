{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mynixos.services.paperless;

  paperless-bkp-script-unwrapped = pkgs.writeShellScriptBin "paperless-bkp-script" ''
    set -e

    EXPORT_DIR="/var/lib/paperless/export"
    ARCHIVE_NAME="paperless_export.tar.gz"
    ARCHIVE_PATH="${cfg.backupDir}/$ARCHIVE_NAME"

    tar -czvf "$ARCHIVE_PATH" -C "$EXPORT_DIR" .

    echo "Backup complete: $ARCHIVE_PATH"
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
        onCalendar = "13:00:00";
      };
      port = 28981;
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
        OnCalendar = "*-*-* 13:05:00";
        Persistent = true;
      };
    };

    networking.firewall = lib.mkIf cfg.openPort {
      allowedTCPPortRanges = [
        {
          from = 28981;
          to = 28981;
        }
      ];
    };
  };
}
