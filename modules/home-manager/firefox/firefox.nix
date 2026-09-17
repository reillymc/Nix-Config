{
  pkgs,
  config,
  ...
}:
let
  prefs = import ./prefs;
in
{
  myhome.state.directories = [
    {
      directory = ".config/mozilla/firefox/default";
      backup.enable = false;
    }
  ];

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
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "np" ];
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
          };
          "Nix Options" = {
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "no" ];
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          google.metaData.alias = "g";
          ddg.metaData.alias = "d";
          bing.metaData.hidden = true;
          ecosia.metaData.hidden = true;
          perplexity.metaData.hidden = true;
          qwant.metaData.hidden = true;
          wikipedia.metaData.hidden = true;
          "ebay-au".metaData.hidden = true;
          "ebay-uk".metaData.hidden = true;
        };
      };

      settings = prefs.default;
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
        # Default = "DuckDuckGo";
      };
      SearchSuggestEnabled = false;

      Preferences = {
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = {
          Value = false;
          Status = "default";
        };
      };
    };
  };
}
