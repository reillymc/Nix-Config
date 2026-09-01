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
  id = "paperless";
  name = "Paperless";
  url = "https://paperless.homelab.reillymc.com/";
}
