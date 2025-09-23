{
  pkgs,
  ...
}:
{
  programs.firefox = {
    enable = true;
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
        };
      };

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 3;
        "sidebar.verticalTabs" = true;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      };
    };
  };
}
