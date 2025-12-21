{
  lib,
  config,
  pkgs,
  ...
}:

let
  base = import ../base.nix { inherit lib config pkgs; };

  app = {
    id = "paperless";
    name = "Paperless";
    url = "http://localhost:28981";
    icon = "paperless.svg";
  };

  cfg = config.mynixos.services.paperless or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox.profiles.${app.id} = {
      id = base.mkProfileId app.id;
      settings = base.webAppSettings;
      userChrome = base.userChromeMinimal;
    };

    xdg.desktopEntries.${app.id} = base.mkWebAppEntry app;
  };
}
