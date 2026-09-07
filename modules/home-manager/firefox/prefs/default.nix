let
  commonPrefs = {
    "browser.toolbars.bookmarks.visibility" = "never";
    "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
    "browser.newtabpage.activity-stream.system.showSponsored" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;

    # Don't open firefox privacy notice tab on first launch
    "browser.rights.3.shown" = true;
    "browser.aboutwelcome.enabled" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = true;

    # Telemetry data-reporting policy: on fresh profiles Firefox opens
    # datareporting.policy.firstRunURL (the mozilla.org privacy page) and/or
    # shows an infobar. The bypass pref suppresses both; it is checked after
    # Nimbus (which can override firstRunURL), so it is the reliable kill
    # switch. Blanking the URL is belt-and-braces.
    "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
    "datareporting.policy.firstRunURL" = "";

    # Separate Terms-of-Use notification flow (also fires on fresh profiles).
    "termsofuse.bypassNotification" = true;
  };

  # TODO: transfer remaining imperative config here, including UI customisation, never save passwords etc
  defaultBasePrefs = {
    "browser.aboutConfig.showWarning" = false;
    "browser.startup.page" = 3;
    "sidebar.verticalTabs" = true;
    "browser.uiCustomization.state" = {
      placements = {
        "widget-overflow-fixed-list" = [ ];

        "unified-extensions-area" = [ ];

        "nav-bar" = [
          "sidebar-button"
          "back-button"
          "forward-button"
          "stop-reload-button"
          "customizableui-special-spring1"
          "vertical-spacer"
          "urlbar-container"
          "customizableui-special-spring2"
          "personal-bookmarks"
          "downloads-button"
          "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
          "ublock0_raymondhill_net-browser-action"
          "offline-qr-code_rugk_github_io-browser-action"
          "unified-extensions-button"
        ];

        "toolbar-menubar" = [ "menubar-items" ];
        "TabsToolbar" = [ ];
        "vertical-tabs" = [ "tabbrowser-tabs" ];
        "PersonalToolbar" = [ ];
      };
      seen = [
        "developer-button"
        "screenshot-button"
        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
        "ublock0_raymondhill_net-browser-action"
        "addon_darkreader_org-browser-action"
        "offline-qr-code_rugk_github_io-browser-action"
      ];

      dirtyAreaCache = [
        "nav-bar"
        "vertical-tabs"
        "PersonalToolbar"
        "toolbar-menubar"
        "TabsToolbar"
        "unified-extensions-area"
      ];

      currentVersion = 23;
      newElementCount = 4;
    };
  };

  webAppBasePrefs = {
    "browser.tabs.inTitlebar" = 1; # Ensure tabs are drawn in the titlebar if needed
    "browser.window.decorations" = true; # Ensure decorations are enabled (if needed)
    "browser.shell.checkDefaultBrowser" = false;
    "browser.fullscreen.autohide" = false;
    "browser.uidensity" = 1; # minimal ui
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "toolkit.legacyUserProfileCustomizations.windowIcon" = true;
    "browser.aboutConfig.showWarning" = false;
    "signon.rememberSignons" = false;

    # Value 14 = default 15 minus the profile-scope bit (1). Auto-disable
    # stays on for user/app scopes, but profile-scope addons are trusted.
    "extensions.autoDisableScopes" = 14;

    # Suppress the first-run welcome/privacy-notice tab on freshly
    # regenerated webapp profiles (no saved homepage_override.mstone).
    "browser.startup.homepage_override.mstone" = "ignore";
    "browser.startup.homepage_welcome_url" = "about:blank";
    "browser.startup.homepage_welcome_url.additional" = "";

    "browser.newtabpage.activity-stream.enabled" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

    # Preferences to force links that open in new tabs to open in new windows
    "browser.link.open_newwindow" = 2; # Open links in a new window
    "browser.link.open_newwindow.restriction" = 0; # No restrictions, force open in new window
    "browser.tabs.loadDivertedInBackground" = false; # Ensure links open in the foreground
  };

  default = defaultBasePrefs // commonPrefs;
  webApp = webAppBasePrefs // commonPrefs;

in
{
  inherit default webApp;
}
