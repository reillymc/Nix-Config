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
  id = "messenger";
  name = "Messenger";
  url = "https://www.messenger.com";
  grantNotifications = true;
}
