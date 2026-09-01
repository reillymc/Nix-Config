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
  id = "navidrome";
  name = "Navidrome";
  url = "https://navidrome.homelab.reillymc.com/";
}
