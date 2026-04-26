{
  pkgs,
  config,
  ...
}:
{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      search = {
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          bing.metaData.hidden = true;
          ecosia.metaData.hidden = true;
          perplexity.metaData.hidden = true;
          qwant.metaData.hidden = true;
          wikipedia.metaData.hidden = true;
          youtube.metaData.hidden = true;
        };
      };

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 3;
        "sidebar.verticalTabs" = true;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      };
    };

    # Check about:policies#documentation for options.
    policies = {

      # Debloat
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      UserMessaging = {
        ExtensionRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = true;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };

      # Security
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      PostQuantumKeyAgreementEnabled = true;

      # Privacy
      DisableTelemetry = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      NetworkPrediction = false;

      SearchEngines = {
        Remove = [
          "eBay"
        ];
        # Add = [
        #   {
        #     "Name" = "DuckDuckGo";
        #     "URLTemplate" = "https://duckduckgo.com/?q={searchTerms}&ia=web&assist=false";
        #     "IconURL" = "https://duckduckgo.com/favicon.ico";
        #     "Alias" = "ddg";
        #     "Description" = "Duckduckgo without AI integrations";
        # ];
        Default = "DuckDuckGo";
      };
      SearchSuggestEnabled = false;

    };
  };
}
