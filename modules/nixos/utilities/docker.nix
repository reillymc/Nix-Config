{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    mynixos.docker.enable = lib.mkEnableOption "Docker";
  };

  config = lib.mkIf config.mynixos.docker.enable {
    virtualisation.docker = {
      enable = true;
      # Speed up boot times (~5s) by not starting the docker daemon until it's actually needed.
      enableOnBoot = false;
    };

    environment.systemPackages = with pkgs; [
      docker
    ];
  };
}
