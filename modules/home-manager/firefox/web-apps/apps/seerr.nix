{
  lib,
  config,
  pkgs,
  ...
}:
let
  base = import ../base.nix { inherit lib config pkgs; };
in
base.mkWebAppModule {
  id = "seerr";
  name = "Seerr";
  url = "https://seerr.homelab.reillymc.com/";
}
