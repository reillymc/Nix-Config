{
  lib,
  theme,
  config,
  pkgs,
  ...
}:
{
  dconf.settings =
    if theme == "light" then
      {
        "org/gnome/desktop/interface" = {
          color-scheme = lib.mkDefault "prefer-light";
        };
      }
    else
      {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

  systemd.user.services.switchToSystemDarkMode = {
    Unit.Description = "Switch to system dark mode configuration";
    Service = {
      ExecStart = "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl start switchToSystemDarkMode.service";
      Type = "oneshot";
    };
  };

  systemd.user.services.switchToSystemLightMode = {
    Unit.Description = "Switch to system light mode configuration";
    Service = {
      ExecStart = "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl start switchToSystemLightMode.service";
      Type = "oneshot";
    };
  };

  systemd.user.timers.switchToSystemDarkMode =
    lib.mkIf (config.myhome.display.theme.darkTime != null)
      {
        Unit.Description = "Timer to switch to system dark mode configuration";
        Install.WantedBy = [ "timers.target" ];
        Timer = {
          Unit = "switchToSystemDarkMode.service";
          OnCalendar = "*-*-* ${config.myhome.display.theme.darkTime}:00";
          Persistent = true;
        };
      };

  systemd.user.timers.switchToSystemLightMode =
    lib.mkIf (config.myhome.display.theme.lightTime != null)
      {
        Unit.Description = "Timer to switch to system light mode configuration";
        Install.WantedBy = [ "timers.target" ];
        Timer = {
          Unit = "switchToSystemLightMode.service";
          OnCalendar = "*-*-* ${config.myhome.display.theme.lightTime}:00";
          Persistent = true;
        };
      };
}
