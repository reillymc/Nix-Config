{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.git = {
    enable = true;
  };

  environment.systemPackages = [ pkgs.git ];
}
