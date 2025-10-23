{
  lib,
  config,
  mynixos,
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
in
{
  config = lib.mkIf mynixos.services.paperless.enable {
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
