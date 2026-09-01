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
  id = "youtube";
  name = "YouTube";
  url = "https://www.youtube.com/feed/subscriptions";
  addons = [
    {
      id = "uBlock0@raymondhill.net";
      slug = "ublock-origin";
    }
    {
      id = "sponsorBlocker@ajay.app";
      slug = "sponsorblock";
    }
  ];
  settings = {
    "browser.theme.content-theme" = 0;
    "browser.theme.toolbar-theme" = 0;
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "browser.startup.homepage" = "https://www.youtube.com/feed/subscriptions";
    "browser.startup.page" = 3;
    # Toolbar layout. Excluding `fxa-toolbar-menu-button' keeps the account
    # button (and its "Recent sessions" panel) out of the toolbar; the
    # widget moves to the palette. `new-tab-button' in TabsToolbar keeps the
    # new tab button at the end of the tab strip (it only shows when placed
    # adjacent to the tabs). dirtyAreaCache must cover every area we place.
    "browser.uiCustomization.state" = {
      placements = {
        "widget-overflow-fixed-list" = [ ];
        "unified-extensions-area" = [ ];
        "nav-bar" = [
          "back-button"
          "forward-button"
          "stop-reload-button"
          "urlbar-container"
          "downloads-button"
          "unified-extensions-button"
        ];
        "toolbar-menubar" = [ "menubar-items" ];
        "TabsToolbar" = [ "new-tab-button" ];
        "PersonalToolbar" = [ ];
      };
      seen = [ ];
      dirtyAreaCache = [
        "widget-overflow-fixed-list"
        "unified-extensions-area"
        "nav-bar"
        "toolbar-menubar"
        "TabsToolbar"
        "PersonalToolbar"
      ];
      currentVersion = 23;
      newElementCount = 0;
    };
  };
  userChrome = ''
    /* New page background color */
    #browser vbox#appcontent tabbrowser,
    #content,
    #tabbrowser-tabpanels,
    browser[type="content-primary"],
    browser[type="content"] > html {
      background: #0F0F0F !important;
    }

    :root {
      --tab-border-radius: 9px !important;
      --toolbox-bgcolor: #0F0F0F !important;
      --toolbox-bgcolor-inactive: #0F0F0F !important;
      --tab-min-height: 32px !important;
      --tab-selected-bgcolor: #272727 !important;
      --urlbar-box-bgcolor: transparent !important;
    }

    #navigator-toolbox {
      flex-direction: row-reverse !important;
      border-bottom: none !important;
      height: 48px;
      /* Base toolbar button padding. The custom var drives the visual
         (image padding) rules below; the Firefox var shrinks the hit area.
         Back/forward and the menu button override both to keep the
         tab-min-height-derived size. */
      --toolbarbutton-inner-padding: 4px;
      --toolbarbutton-padding-inner: 4px;
    }

    #toolbar-menubar {
      display: none
    }

    .titlebar-spacer {
      display: none;
    }

    /* Move tabs into the main header space */
    #TabsToolbar {
      background-color: transparent;
      border-bottom-width: 0xp;
      align-items: center !important;
      margin-right: 48px;
    }

    /* Adjust the height for a compact look */
    #TabsToolbar, #nav-bar {
      --toolbar-height: 40px; /* Adjust this value for your preferred size */
    }

    /* Hide navigation bar items when tabs are active */
    #urlbar-container:not(:focus-within) {
      width: 0px !important;
      opacity: 0 !important;

      .urlbar-background, #searchbar{
        background-color: initial !important;
      }
    }

    #urlbar-container {
      transition: width 0.25s;
      transition-delay: 0.06s;
        --toolbar-field-focus-border-color: #0F0F0F !important;
    }

    .urlbar[breakout] {
      & > .urlbar-input-container {
        width: 100%;
        height: 100%;
      }
    }

    #urlbar[breakout][breakout-extend]:not([open]) > #urlbar-background {
       box-shadow: none !important;
    }


    .page-action-buttons, tracking-protection-icon-container, identity-box {
      display: none;
    }


    #nav-bar.browser-toolbar {
      background-color:transparent !important;
    }

    .toolbarbutton-1 > image {
      padding: var(--toolbarbutton-inner-padding) !important;
      border-radius: var(--tab-border-radius) !important;
    }

    toolbar .toolbarbutton-1 {
      padding: 0;
    }

    #PanelUI-button {
      position: fixed;
      right: 0;
      top: 8px;
    }

    #PanelUI-menu-button > stack > image {
      width: calc(2 * var(--toolbarbutton-inner-padding) + 16px) !important;
      height: calc(2 * var(--toolbarbutton-inner-padding) + 16px);
      padding: var(--toolbarbutton-inner-padding) !important;
    }

    #PanelUI-menu-button > stack {
      border-radius: var(--tab-border-radius) !important;
      padding: 0 !important;
    }

    #PanelUI-menu-button {
      --toolbarbutton-inner-padding: calc((var(--tab-min-height) - 16px) / 2);
      --toolbarbutton-padding-inner: calc((var(--tab-min-height) - 16px) / 2);
    }

    #forward-button, #back-button {
      --toolbarbutton-inner-padding: calc((var(--tab-min-height) - 16px) / 2);
      --toolbarbutton-padding-inner: calc((var(--tab-min-height) - 16px) / 2);
    }

    .tabbrowser-tab[fadein]:not([pinned]):not([style*="max-width"]) {
    	max-width: 100% !important;
    }
  '';
}
