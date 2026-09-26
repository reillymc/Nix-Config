{
  lib,
  config,
  hostname,
  ...
}:
let
  schedule = config.mynixos.theme.schedule;
  isScheduled = schedule.darkTime != null && schedule.lightTime != null;
in
{
  options.mynixos.theme.schedule = lib.mkOption {
    type = lib.types.submodule {
      options = {
        lightTime = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Time of day to switch to light theme (HH:MM).";
        };

        darkTime = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Time of day to switch to dark theme (HH:MM).";
        };
      };
    };
    default = { };
    description = "Configuration for automatically switching system theme. Both `lightTime` and `darkTime` must be set for the theme specialisation and timers to be created; leave unset on hosts without a desktop theme.";
  };

  config = {
    specialisation = lib.mkIf isScheduled {
      light.configuration.home-manager.extraSpecialArgs.theme = "light";
    };

    systemd.services.activateDesiredSystemTheme = lib.mkIf isScheduled {
      description = "Active the desired system theme based on current time";
      serviceConfig = {
        ExecStart = "/run/current-system/sw/bin/${hostname}-theme";
        Type = "oneshot";
      };
    };

    systemd.timers.activateDesiredSystemThemeOnSchedule = lib.mkIf isScheduled {
      description = "Timer to trigger the automatic set theme script";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "activateDesiredSystemTheme.service";
        OnCalendar = [
          "*-*-* ${schedule.darkTime}:00"
          "*-*-* ${schedule.lightTime}:00"
        ];
        Persistent = true;
      };
    };

    systemd.timers.activateDesiredSystemThemeOnBoot = lib.mkIf isScheduled {
      description = "Timer to trigger the automatic set theme script";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "activateDesiredSystemTheme.service";
        OnBootSec = "0";
      };
    };
  };
}
