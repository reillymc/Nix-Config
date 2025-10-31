{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    mynixos.via.enable = lib.mkEnableOption "enables via";
  };

  config = lib.mkIf config.mynixos.via.enable {
    environment.systemPackages = with pkgs; [
      via
    ];

    services.udev.packages = with pkgs; [
      via
    ];

    mynixos.myUnfreePackages = [
      "via"
    ];
  };
}
