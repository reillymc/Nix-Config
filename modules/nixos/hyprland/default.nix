{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./thumbnailers.nix ];

  options = {
    mynixos.hyprland.enable = lib.mkEnableOption "Hyprland";
  };

  config = lib.mkIf config.mynixos.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    services = {
      displayManager.defaultSession = "hyprland-uwsm";
      gnome.core-apps.enable = true;
      gnome.sushi.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-console
      gnome-connections
      gnome-music
      evince
      geary
      totem
    ];

    environment.systemPackages = with pkgs; [
      kitty
    ];

    xdg.portal = {
      enable = true;
      config = {
        hyprland = {
          "org.freedesktop.impl.portal.FileChooser" = "gnome";
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };
}
