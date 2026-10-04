{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}:
{
  options.mynixos.online-accounts.enable = lib.mkEnableOption "GNOME Online Accounts (CalDAV/CardDAV) with Evolution Data Server";

  config = lib.mkIf config.mynixos.online-accounts.enable {
    services.gnome.evolution-data-server.enable = true;
    services.gnome.gnome-online-accounts.enable = true;
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = [
      pkgs.gnome-calendar
      pkgs.gnome-contacts
      nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.planify # Need minimum 4.20 for CalDAV support
    ];
  };
}
