{
  lib,
  theme,
  config,
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
