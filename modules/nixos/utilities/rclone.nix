{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    mynixos.rclone.enable = lib.mkEnableOption "enables rclone";
  };

  config = lib.mkIf config.mynixos.rclone.enable {
    environment.systemPackages = with pkgs; [
      rclone
    ];
  };
}
