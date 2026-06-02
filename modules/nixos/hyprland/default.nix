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
    services.displayManager.defaultSession = "hyprland-uwsm";

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

    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
