{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.mynixos.theme.user = lib.mkOption {
    type = lib.types.str;
    description = "The user allowed to switch system theme";
  };

  options.mynixos.theme.auto = lib.mkOption {
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
      description = "Switch to system dark mode configuration";
      serviceConfig = {
        ExecStart = "/nix/var/nix/profiles/system/specialisation/dark/bin/switch-to-configuration switch";
        Type = "oneshot";
      };
    };

    systemd.services.switchToSystemLightMode = {
      description = "Switch to system light mode configuration";
      serviceConfig = {
        ExecStart = "/nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch";
        Type = "oneshot";
      };
    };

    systemd.user.timers.switchToSystemDarkMode = lib.mkIf (config.mynixos.theme.auto.darkTime != null) {
      description = "Timer to switch to system dark mode configuration";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "switchToSystemDarkMode.service";
        OnCalendar = "*-*-* ${config.mynixos.theme.auto.darkTime}:00";
        Persistent = true;
      };
    };

    systemd.user.timers.switchToSystemLightMode =
      lib.mkIf (config.mynixos.theme.auto.lightTime != null)
        {
          description = "Timer to switch to system light mode configuration";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            Unit = "switchToSystemLightMode.service";
            OnCalendar = "*-*-* ${config.mynixos.theme.auto.lightTime}:00";
            Persistent = true;
          };
        };

    security.sudo.extraRules = [
      {
        users = [ config.mynixos.theme.user ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl start switchToSystemDarkMode.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl start switchToSystemLightMode.service";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
