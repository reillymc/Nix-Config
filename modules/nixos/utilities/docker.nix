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
      daemon.settings.shutdown-timeout = 5;
      autoPrune.enable = true;
    };

    environment.systemPackages = with pkgs; [
      docker
    ];
  };
}
