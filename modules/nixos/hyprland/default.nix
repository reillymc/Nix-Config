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

    services = {
      displayManager.defaultSession = "hyprland-uwsm";
      gnome.core-apps.enable = true;
      gnome.sushi.enable = true;

      # Required for calendar
      gnome.evolution-data-server.enable = true;
      gnome.gnome-online-accounts.enable = true;
      gnome.gnome-keyring.enable = true;
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
        hyprland = {
          "org.freedesktop.impl.portal.FileChooser" = "nautilus"; # TODO: currently this causes a ~10-20s delay when starting/restarting xdg-desktop-portal.
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };
}
