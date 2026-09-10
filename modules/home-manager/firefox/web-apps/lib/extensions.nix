{ lib, mkUuid }:
let
  newTabOverrideId = "newtaboverride@agenedia.com";
  newTabOverrideSlug = "new-tab-override";

  originOfUrl =
    url:
    let
      noScheme = lib.removePrefix "https://" url;
    in
    "https://" + (builtins.head (builtins.split "/" noScheme));

  webAppExtensionPrefs =
    extraAddons:
    let
      ids = (map (a: a.id) extraAddons) ++ [ newTabOverrideId ];
      uuids = builtins.listToAttrs (
        map (id: {
          name = id;
          value = mkUuid id;
        }) ids
      );
    in
    {
      "extensions.webextensions.uuids" = builtins.toJSON uuids;
    };

  mkWebAppExtensionSettings =
    extraAddons:
    lib.listToAttrs (
      [
        {
          name = "*";
          value = {
            installation_mode = "blocked";
          };
        }
      ]
      ++
        map
          (a: {
            name = a.id;
            value = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${a.slug}/latest.xpi";
              updates_disabled = true;
            };
          })
          (
            extraAddons
            ++ [
              {
                id = newTabOverrideId;
                slug = newTabOverrideSlug;
              }
            ]
          )
    );
in
{
  inherit
    newTabOverrideId
    newTabOverrideSlug
    originOfUrl
    webAppExtensionPrefs
    mkWebAppExtensionSettings
    ;
}
