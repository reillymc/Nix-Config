{
  lib,
  config,
  pkgs,
  ...
}:
let
  base = import ../base.nix { inherit lib config pkgs; };
  prefs = import ../../prefs;
  userChrome = import ../../user-chrome;

  app = {
    id = "paperless";
    name = "Paperless";
    url = "https://paperless.homelab.reillymc.com/";
    icon = "paperless.svg";
  };
in
{
  options = {
    myhome.web-apps.${app.id}.enable = lib.mkEnableOption "${app.name} web app";
  };

  config = lib.mkIf config.myhome.web-apps.${app.id}.enable {
    programs.firefox.profiles.${app.id} = {
      id = base.mkProfileId app.id;
      settings = prefs.webApp;
      userChrome = userChrome.webAppSingleMinimal;
    };

    xdg.desktopEntries.${app.id} = base.mkWebAppEntry app;
  };
}
