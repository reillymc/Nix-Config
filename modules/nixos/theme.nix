{
  lib,
  config,
  ...
}:
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
    description = "Configuration for automatically switching system theme.";
  };

  config = {
    specialisation.light.configuration = {
      home-manager.extraSpecialArgs.theme = "light";
    };
    specialisation.dark.configuration = {
      home-manager.extraSpecialArgs.theme = "dark";
    };

    systemd.services.switchToSystemDarkMode = {
      description = "Switch system to dark mode";
      serviceConfig = {
        ExecStart = "/nix/var/nix/profiles/system/specialisation/dark/bin/switch-to-configuration switch";
        Type = "oneshot";
      };
    };

    systemd.services.switchToSystemLightMode = {
      description = "Switch system to light mode";
      serviceConfig = {
        ExecStart = "/nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch";
        Type = "oneshot";
      };
    };

    systemd.timers.switchToSystemDarkMode = lib.mkIf (config.mynixos.theme.schedule.darkTime != null) {
      description = "Timer to switch to system dark mode configuration";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "switchToSystemDarkMode.service";
        OnCalendar = "*-*-* ${config.mynixos.theme.schedule.darkTime}:00";
        Persistent = true;
      };
    };

    systemd.timers.switchToSystemLightMode =
      lib.mkIf (config.mynixos.theme.schedule.lightTime != null)
        {
          description = "Timer to switch to system light mode configuration";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            Unit = "switchToSystemLightMode.service";
            OnCalendar = "*-*-* ${config.mynixos.theme.schedule.lightTime}:00";
            Persistent = true;
          };
        };
  };
}
