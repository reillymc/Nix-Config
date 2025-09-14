{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    # TODO: control this with same variable as home manager hyprland
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
  };
}
