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
  id = "proton-mail";
  name = "Proton Mail";
  url = "https://mail.proton.me/u/1/inbox";
  grantNotifications = true;
}
