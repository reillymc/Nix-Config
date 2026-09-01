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
  id = "whatsapp";
  name = "WhatsApp";
  url = "https://web.whatsapp.com";
}
