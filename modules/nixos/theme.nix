{
  ...
}:
{
  specialisation.light.configuration = {
    home-manager.extraSpecialArgs.theme = "light";
  };
  specialisation.dark.configuration = {
    home-manager.extraSpecialArgs.theme = "dark";
  };

  systemd.services.switchToSystemDarkMode = {
    description = "Switch to system dark mode configuration";
    serviceConfig = {
      ExecStart = "/nix/var/nix/profiles/system/specialisation/dark/bin/switch-to-configuration switch";
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.services.switchToSystemLightMode = {
    description = "Switch to system light mode configuration";
    serviceConfig = {
      ExecStart = "/nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch";
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.switchToSystemDarkMode = {
    description = "Timer to switch to system dark mode configuration";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 18:30:00";
      Persistent = true;
    };
  };

  systemd.timers.switchToSystemLightMode = {
    description = "Timer to switch to system light mode configuration";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 08:00:00";
      Persistent = true;
    };
  };
}
