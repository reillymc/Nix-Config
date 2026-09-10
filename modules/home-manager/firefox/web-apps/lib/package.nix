{
  lib,
  pkgs,
  baselinePolicies,
  mkWebAppExtensionSettings,
  mkWebAppAutoconfig,
  newTabOverrideId,
}:
{
  mkWebAppPackage =
    app: extraAddons:
    let
      appPolicies = app.policies or { };
      userscripts = app.userscripts or [ ];
      autoconfigJs = lib.optionals (userscripts != [ ]) [
        (mkWebAppAutoconfig app.id userscripts)
      ];
    in
    pkgs.firefox.override (old: {
      extraPolicies =
        (old.extraPolicies or { })
        // baselinePolicies
        // appPolicies
        // {
          ExtensionSettings =
            (mkWebAppExtensionSettings extraAddons) // (appPolicies.ExtensionSettings or { });
          "3rdparty" = {
            Extensions = ((appPolicies."3rdparty" or { }).Extensions or { }) // {
              ${newTabOverrideId} = {
                type = "custom_url";
                url = app.url;
                focus_website = true;
              };
            };
          };
        };
      extraPrefsFiles = (old.extraPrefsFiles or [ ]) ++ autoconfigJs;
    });
}
