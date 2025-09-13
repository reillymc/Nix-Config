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

  home.packages = [ pkgs.git ];
}
