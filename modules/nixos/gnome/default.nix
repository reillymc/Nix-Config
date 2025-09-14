{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    mynixos.gnome.enable = lib.mkEnableOption "enables gnome";
  };

  config = lib.mkIf config.mynixos.gnome.enable {
    # Enable the GNOME Desktop Environment.
    services.xserver.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.gsconnect
      gnomeExtensions.clipboard-history
      gnomeExtensions.night-theme-switcher
    ];
  };
}
