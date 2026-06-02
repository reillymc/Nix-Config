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
      nautilus

      # Register Nautilus as an XDG Desktop Portal FileChooser
      (runCommandLocal "nautilus-portal" { } ''
        mkdir -p $out/share/xdg-desktop-portal/portals
        cat > $out/share/xdg-desktop-portal/portals/nautilus.portal <<EOF
        [portal]
        DBusName=org.gnome.Nautilus
        Interfaces=org.freedesktop.impl.portal.FileChooser
        EOF
      '')
    ];

    xdg.portal = {
      enable = true;
      config = {
        common.default = "*";
        hyprland = {
          "org.freedesktop.impl.portal.FileChooser" = "nautilus";
          default = [ "gtk" ]; # Standard fallback for other portals
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
