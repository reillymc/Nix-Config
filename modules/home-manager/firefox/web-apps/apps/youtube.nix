{
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
    {
      id = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
      slug = "return-youtube-dislikes";
    }
  ];
  # Currently needed in order to persist session state
  persistWholeProfile = true;
  search = {
    force = true;
    default = "youtube";
    privateDefault = "youtube";
    order = [ "youtube" ];
    engines = {
      youtube = {
        name = "YouTube";
        icon = "https://www.youtube.com/favicon.ico";
        definedAliases = [ "yt" ];
        urls = [
          {
            template = "https://www.youtube.com/results";
            params = [
              {
                name = "search_query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
      };
      google.metaData.hidden = true;
      ddg.metaData.hidden = true;
      bing.metaData.hidden = true;
      ecosia.metaData.hidden = true;
      qwant.metaData.hidden = true;
      perplexity.metaData.hidden = true;
      wikipedia.metaData.hidden = true;
      "ebay-au".metaData.hidden = true;
      "ebay-uk".metaData.hidden = true;
    };
  };
  policies = {
    "3rdparty".Extensions."uBlock0@raymondhill.net" = {
      toOverwrite.filters = [
        "! Hide all videos with the shorts indicator"
        "www.youtube.com##ytd-thumbnail-overlay-time-status-renderer[overlay-style=\"SHORTS\"]:upward(ytd-video-renderer)"
        ""
        "! Remove generic shorts shelf except on history page"
        "www.youtube.com##:matches-path(/^(?!\\/feed\\/history).*$/)ytd-reel-shelf-renderer"
        ""
        "! Remove rich shelf shorts section"
        "www.youtube.com##ytd-rich-shelf-renderer[is-shorts],ytd-rich-shelf-renderer[is-shorts]:upward(ytd-rich-section-renderer)"
        "www.youtube.com##ytd-rich-item-renderer[rendered-from-rich-grid] ytm-shorts-lockup-view-model:upward(ytd-rich-item-renderer[rendered-from-rich-grid])"
        ""
        "! Hide shorts button in sidebar"
        "www.youtube.com##ytd-guide-entry-renderer:has(.ytd-guide-entry-renderer[title=\"Shorts\"])"
        "! Tablet resolution"
        "www.youtube.com##ytd-mini-guide-entry-renderer:has(.ytd-mini-guide-entry-renderer[title=\"Shorts\"])"
        ""
        "! Hide shorts tab on channel pages"
        "www.youtube.com##yt-tab-shape[tab-title=\"Shorts\"]"
        ""
        "! Hide shorts filter/category on top of homepage and search pages"
        "www.youtube.com##yt-chip-cloud-chip-renderer:has(.ytChipShapeInactive:has-text(/^Shorts$/i))"
        ""
        "! Hide shorts sections on search page"
        "www.youtube.com##ytm-shorts-lockup-view-model-v2:upward(grid-shelf-view-model)"
        ""
        "! Hide most relevant on subscriptions page"
        "www.youtube.com##ytd-browse[page-subtype=\"subscriptions\"] ytd-rich-section-renderer"
      ];
    };
  };
  settings = {
    "browser.theme.content-theme" = 2;
    "browser.theme.toolbar-theme" = 2;
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "browser.startup.page" = 3;
    "browser.uiCustomization.state" = {
      placements = {
        "widget-overflow-fixed-list" = [ ];
        "unified-extensions-area" = [
          "ublock0_raymondhill_net-browser-action"
          "sponsorblocker_ajay_app-browser-action"
          "newtaboverride_agenedia_com-browser-action"
          "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
        ];
        "nav-bar" = [
          "back-button"
          "forward-button"
          "stop-reload-button"
          "urlbar-container"
          "downloads-button"
          "unified-extensions-button"
        ];
        "toolbar-menubar" = [ "menubar-items" ];
        "TabsToolbar" = [
          "tabbrowser-tabs"
          "new-tab-button"
        ];
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
      --toolbarbutton-inner-padding: 4px !important;
    }

    #navigator-toolbox,
    #nav-bar,
    #TabsToolbar,
    #PersonalToolbar {
      background-color: var(--toolbox-bgcolor) !important;
      background-image: none !important;
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
      border-bottom-width: 0px;
      align-items: center !important;
      margin-right: 48px;
    }

    .tabbrowser-tab[selected] .tab-background {
      background: var(--tab-selected-bgcolor) !important;
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
