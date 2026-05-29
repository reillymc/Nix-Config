{
  lib,
  pkgs,
  config,
  mynixos,
  ...
}:
let
  hyprland-bitwarden-handler = pkgs.writeShellScriptBin "hyprland-bitwarden-handler" ''
    set -euo pipefail

    windowtitlev2() {
      IFS=',' read -r -a args <<< "$1"
      args[0]="''${args[0]#*>>}"

      if [[ ''${args[1]} == "Extension: (Bitwarden Password Manager) - — Mozilla Firefox" ]]; then
        hyprctl --batch "\
          dispatch setfloating address:0x''${args[0]}; \
          dispatch resizewindowpixel exact 620 700, address:0x''${args[0]}; \
          dispatch centerwindow; \
        "
      fi
    }

    handle() {
      case "$1" in
        windowtitlev2\>*)
          windowtitlev2 "$1"
          ;;
      esac
    }

    SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

    echo "Connecting to: $SOCKET"

    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$SOCKET" \
      | while read -r line; do
          handle "$line"
        done
  '';
in
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

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 3;
        "sidebar.verticalTabs" = true;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
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

    };
  };

  systemd.user.services.hyprland-bitwarden-handler = lib.mkIf mynixos.hyprland.enable {
    Unit = {
      Description = "Hyprland Bitwarden Window Handler";

      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${hyprland-bitwarden-handler}/bin/hyprland-bitwarden-handler";

      Restart = "always";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
