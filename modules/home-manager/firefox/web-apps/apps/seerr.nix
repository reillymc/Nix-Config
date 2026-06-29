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
    id = "jellyseerr";
    name = "Seerr";
    url = "https://seerr.homelab.reillymc.com/";
    icon = "seerr.svg";
  };
in
{
  options = {
    myhome.web-apps.${app.id}.enable = lib.mkEnableOption "${app.name} web app";
  };

  config = lib.mkIf config.myhome.web-apps.${app.id}.enable {
    # Firefox profile definition
    programs.firefox.profiles.${app.id} = {
      id = base.mkProfileId app.id;
      settings = prefs.webApp;
      userChrome = userChrome.webAppSingleMinimal;
    };

    # XDG desktop entry definition
    xdg.desktopEntries.${app.id} = base.mkWebAppEntry app;
  };
}
