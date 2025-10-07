{
  config,
  pkgs,
  configDir,
  mynixos,
  lib,
  ...
}:
let
  webApps = [
    # Personal Profile
    {
      id = "messenger";
      profile = "messenger";
      name = "Messenger";
      url = "https://www.messenger.com";
      icon = "messenger.png";
    }
    {
      id = "proton-mail";
      profile = "proton-mail";
      name = "Proton Mail";
      url = "https://mail.proton.me/u/1/inbox";
      icon = "proton-mail.svg";
    }
    {
      id = "immich";
      profile = "immich";
      name = "Immich";
      url = "http://silverserver:2283";
      icon = "immich.svg";
    }
    {
      id = "navidrome";
      profile = "navidrome";
      name = "Navidrome";
      url = "http://silverserver:4533/app/";
      icon = "navidrome.png";
    }
    {
      id = "jellyfin";
      profile = "jellyfin";
      name = "Jellyfin";
      url = "http://hupboard.home:8096/web";
      icon = "jellyfin.svg";
    }
    {
      id = "jellyseerr";
      profile = "jellyfin";
      name = "Jellyseerr";
      url = "http://hupboard.home:5055";
      icon = "jellyseerr.svg";
    }
    {
      id = "youtube";
      profile = "youtube";
      name = "YouTube";
      url = "https://www.youtube.com/feed/subscriptions";
      icon = "youtube.png";
    }
  ]
  ++ lib.lists.optionals mynixos.services.paperless.enable [
    {
      id = "paperless";
      profile = "paperless";
      name = "Paperless";
      url = "http://localhost:28981";
      icon = "paperless.svg";
    }
  ];

  # Common settings for all profiles (user.js settings
  webAppSettings = {
    "browser.tabs.inTitlebar" = 1; # Ensure tabs are drawn in the titlebar if needed
    "browser.window.decorations" = true; # Ensure decorations are enabled (if needed)
    "browser.shell.checkDefaultBrowser" = false;
    "browser.fullscreen.autohide" = false;
    "browser.uidensity" = 1; # minimal ui
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "toolkit.legacyUserProfileCustomizations.windowIcon" = true;
    "browser.aboutConfig.showWarning" = false;

    # Preferences to force links that open in new tabs to open in new windows
    "browser.link.open_newwindow" = 2; # Open links in a new window
    "browser.link.open_newwindow.restriction" = 0; # No restrictions, force open in new window
    "browser.tabs.loadDivertedInBackground" = false; # Ensure links open in the foreground
    "permissions.default.desktop-notification" = 1; # Allow notifications
  };

  # aggressive userChrome
  userChrome = ''
    #TabsToolbar, #identity-box, #tabbrowser-tabs, #TabsToolbar { display: none !important; }
    #nav-bar { visibility: collapse !important; }
  '';

  /*
    userChrome = ''
      #TabsToolbar, #nav-bar { visibility: collapse !important; }
    '';
  */
  # userChromeRelaxed = ''
  #   #tabbrowser-tabs tab:only-of-type,
  #   #tabbrowser-tabs tab:only-of-type + #tabs-newtab-button {
  #     display: none !important;
  #   }
  #   #tabbrowser-tabs, #tabbrowser-arrowscrollbox {
  #     min-height: 0 !important;
  #   }
  #   /* Keep page title in window title */
  #   .titlebar-placeholder[type="pre-tabs"],
  #   .titlebar-placeholder[type="post-tabs"] { display: none !important; }

  #   #tabbrowser-tabs .tabbrowser-tab:only-of-type {
  #     visibility: collapse !important;
  #   }

  #   #tabbrowser-tabs, #tabbrowser-arrowscrollbox {
  #     min-height: 0 !important;
  #   }

  #   #tabbrowser-tabs,
  #   #tabbrowser-tabs .scrollbox-innerbox {
  #     min-height: 0 !important;
  #     padding-block: 0 !important;
  #   }
  # '';

  userChromeYT = ''
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

  webAppSettingsYT = webAppSettings // {
    "browser.theme.content-theme" = 0;
    "browser.theme.toolbar-theme" = 0;
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "browser.startup.homepage" = "https://www.youtube.com/feed/subscriptions";
    "browser.startup.page" = 3;
  };

in
{
  xdg.desktopEntries = builtins.listToAttrs (
    map (app: {
      name = app.id;
      value = {
        name = app.name;
        type = "Application";
        exec = ''${pkgs.firefox}/bin/firefox -no-remote --profile "${config.home.homeDirectory}/.mozilla/firefox/${app.profile}" --class "${app.id}" --name "${app.name}" --new-window "${app.url}"'';
        icon = "${configDir}/resources/icons/${app.icon}";
        categories = [ "X-Internet" ];
        settings = {
          Keywords = "WebApp";
          StartupWMClass = app.id;
        };
      };
    }) webApps
  );

  programs.firefox = {
    profiles = {
      messenger = {
        settings = webAppSettings;
        userChrome = userChrome;
        id = 1;
      };
      proton-mail = {
        settings = webAppSettings;
        userChrome = userChrome;
        id = 2;
      };
      immich = {
        settings = webAppSettings;
        userChrome = userChrome;
        id = 3;
      };
      navidrome = {
        settings = webAppSettings;
        userChrome = userChrome;
        id = 4;
      };
      jellyfin = {
        settings = webAppSettings;
        userChrome = userChrome;
        id = 5;
      };
      youtube = {
        settings = webAppSettingsYT;
        userChrome = userChromeYT;
        id = 6;
      };
      paperless = {
        settings = webAppSettings;
        userChrome = userChrome;
        id = 3254;
      };
    };
  };
}
