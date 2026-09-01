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
  id = "immich";
  name = "Immich";
  url = "https://immich.homelab.reillymc.com/";
}
