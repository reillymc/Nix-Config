{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = [ pkgs.blackbox-terminal ];
}
