{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    mynixos.docker.enable = lib.mkEnableOption "enables docker";
  };

  config = lib.mkIf config.mynixos.docker.enable {
    virtualisation.docker = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      docker
    ];
  };
}
