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
