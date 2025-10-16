{
  config,
  lib,
  pkgs,
  ...
}:
let
  paperless-bkp-script-unwrapped = pkgs.writeShellScriptBin "paperless-bkp-script" ''
    set -e

    EXPORT_DIR="/var/lib/paperless/export"
    ARCHIVE_NAME="paperless_export.tar.gz"
    ARCHIVE_PATH="${config.mynixos.services.paperless.backupDir}/$ARCHIVE_NAME"

    # Create tar.gz archive
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
  options = {
    mynixos.services.paperless = {
      enable = lib.mkEnableOption "enables paperless";
      backupDir = lib.mkOption {
        type = lib.types.str;
        description = "Directory to back up paperless data to.";
      };
      openPort = lib.mkEnableOption "open firewall port for paperless web interface (28981)";
    };
  };

  config = lib.mkIf config.mynixos.services.paperless.enable {
    services.paperless = {
      enable = true;
      exporter = {
        enable = true;
        onCalendar = "13:00:00";
      };
      port = 28981;
    }
    // (lib.optionalAttrs config.mynixos.services.paperless.openPort {
      address = "0.0.0.0";
    });

    # Hacky way to get backup into home folder for rclone backup. Ideally would run paperless as home manager module if it existed
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

    # Open firewall port for paperless web interface
    networking.firewall = lib.mkIf config.mynixos.services.paperless.openPort {
      allowedTCPPortRanges = [
        {
          from = 28981;
          to = 28981;
        }
      ];
    };
  };
}
