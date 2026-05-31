{
  lib,
  config,
  pkgs,
  ...
}:
let
  base = import ../base.nix { inherit lib config pkgs; };

  app = {
    id = "immich";
    name = "Immich";
    url = "https://immich.homelab.reillymc.com/";
    icon = "immich.svg";
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
      settings = base.webAppSettings;
      userChrome = base.userChromeMinimal;
    };

    # XDG desktop entry definition
    xdg.desktopEntries.${app.id} = base.mkWebAppEntry app;
  };
}
