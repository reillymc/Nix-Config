{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./thumbnailers.nix ];

  options = {
    mynixos.hyprland.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.mynixos.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    services.gnome.core-apps.enable = true;
    services.gnome.core-os-services.enable = true;
    services.gnome.sushi.enable = true;

    environment.gnome.excludePackages = (
      with pkgs;
      [
        gnome-console
        gnome-connections
        gnome-music
        evince
        geary
        totem
      ]
    );

    environment.systemPackages = with pkgs; [
      kitty
    ];

    systemd.services.switchToDarkCursor = {
      description = "Switch to dark cursor (hyprland)";
      serviceConfig = {
        ExecStart = "hyprctl setcursor Bibata-Modern-Ice 24";
        Type = "oneshot";
      };
    };

    systemd.services.switchToLightCursor = {
      description = "Switch to light cursor (hyprland)";
      serviceConfig = {
        ExecStart = "hyprctl setcursor Bibata-Modern-Classic 24";
        Type = "oneshot";
      };
    };

    systemd.timers.switchToDarkCursor = {
      description = "Timer to switch to dark cursor (hyprland)";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 18:30:00";
        Persistent = true;
      };
    };

    systemd.timers.switchToLightCursor = {
      description = "Timer to switch to light cursor (hyprland)";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 08:00:00";
        Persistent = true;
      };
    };

  };
}
