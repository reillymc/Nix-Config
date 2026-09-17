{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    mynixos.via.enable = lib.mkEnableOption "VIA keyboard configurer";
  };

  config = lib.mkIf config.mynixos.via.enable {
    environment.systemPackages = with pkgs; [
      via
    ];

    services.udev.packages = with pkgs; [
      via
    ];

    mynixos.unfreePackages = [
      "via"
    ];
  };
}
