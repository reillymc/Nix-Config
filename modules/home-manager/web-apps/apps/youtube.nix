{
  lib,
  config,
  pkgs,
  ...
}:
let
  base = import ../base.nix { inherit lib config pkgs; };

  app = {
    id = "youtube";
    name = "YouTube";
    url = "https://www.youtube.com/feed/subscriptions";
    icon = "youtube.svg";
  };

  cfg = config.myhome.web-apps.${app.id};

  userChrome = ''
    /* New page background color */
    #browser vbox#appcontent tabbrowser,
    #content,
    #tabbrowser-tabpanels,
    browser[type="content-primary"],
    browser[type="content"] > html {
        background: #0f0f0f !important;
    }

    #TabsToolbar {
        background: #0f0f0f !important;
    }

    /* Add space to drag window when tabs are full */
    #personal-bookmarks {
        margin-left: 84px !important;
    }

    /* Remove awkward space near window controls */
    .titlebar-spacer {
        width: 0px !important;
    }

    #alltabs-button {
        display: none;
    }

    .titlebar-buttonbox {
        z-index: 0 !important;
    }

    .tabbrowser-tab .tab-background {
        background-color: #1d1d1d !important;
        box-shadow: none !important;
    }

    .tabbrowser-tab[selected] .tab-background {
        background-color: #444 !important;
    }

    .tabbrowser-tab:hover .tab-background {
        background-color: #555 !important;
    }

    .tabbrowser-tab {
        color: #ddd !important;
    }

    .tabbrowser-tab[selected] {
        color: white !important;
    }

    .tabbrowser-tab:hover {
        color: white !important;
    }

    .tabbrowser-tab[fadein]:not([pinned]):not([style*="max-width"]) {
        max-width: 100% !important;
    }

    #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs])
        > #tabbrowser-arrowscrollbox
        > .tabbrowser-tab[first-visible-unpinned-tab] {
        margin-inline-start: 0px !important;
    }
  '';

  settings = base.webAppSettings // {
    "browser.theme.content-theme" = 0;
    "browser.theme.toolbar-theme" = 0;
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "browser.startup.homepage" = "https://www.youtube.com/feed/subscriptions";
    "browser.startup.page" = 3;
  };
in
{
  options = {
    myhome.web-apps.${app.id}.enable = lib.mkEnableOption "${app.name} web app";
  };

  config = lib.mkIf cfg.enable {
    # Firefox profile definition
    programs.firefox.profiles.${app.id} = {
      id = base.mkProfileId app.id;
      settings = settings;
      userChrome = userChrome;
    };

    # XDG desktop entry definition
    xdg.desktopEntries.${app.id} = base.mkWebAppEntry app;
  };
}
