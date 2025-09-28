{
  lib,
  mynixos,
  config,
  pkgs,
  ...
}:
{
  options = {
    myhome.rclone.remote = lib.mkOption {
      type = lib.types.str;
      description = "rclone remote to back up to.";
      example = "s3-remote:";
    };
    myhome.rclone.filter = lib.mkOption {
      type = lib.types.str;
      default = ''
        # Exclude everything else
        - *
      '';
      description = "rclone filter config.";
      example = ''
        # Exclude
        - node_modules/
        - logs/

        # Include
        + /Documents/**
        + /Pictures/**

        # Exclude everything else
        - *
      '';
    };
  };

  config = lib.mkIf mynixos.rclone.enable {
    home.file.rclone_filter = {
      text = config.myhome.rclone.filter;
      target = ".config/rclone/filter.txt";
    };

    systemd.user.services."rclone-backup" = {
      Unit = {
        Description = "Rclone backup service";
      };
      Service = {
        ExecStart = "${pkgs.rclone}/bin/rclone copy -P --fast-list --filter-from ${config.home.homeDirectory}/.config/rclone/filter.txt --log-file ${config.home.homeDirectory}/.local/share/rclone/rclone.log --log-level INFO ${config.home.homeDirectory}/ ${config.myhome.rclone.remote}:";
        Type = "oneshot";
      };
    };

    systemd.user.timers."rclone-backup" = {
      Unit = {
        Description = "Timer to run rclone backup daily";
      };
      Timer = {
        OnCalendar = "*-*-* 16:00:00";
        Unit = "rclone-backup.service";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
