{
  lib,
  mkProfileId,
  webAppExtensionPrefs,
  mkWebAppPackage,
  mkWebAppEntry,
  originOfUrl,
  webAppPrefs,
  defaultUserChrome,
  iconsDir,
}:
{
  # Pure per-app derivation: profile + desktop entry + icon assertion,
  # returned as plain values. Consumed in default.nix as option values
  # (safe); never used to shape config structure (would self-cycle).
  mkAppConfig =
    id: app:
    let
      effectivePolicies =
        app.policies
        // lib.optionalAttrs app.grantNotifications {
          Permissions.Notifications.Allow = [ (originOfUrl app.url) ];
        };

      effectiveSettings = {
        "browser.startup.homepage" = app.url;
      }
      // lib.optionalAttrs app.savePasswords {
        "signon.rememberSignons" = true;
      }
      // app.settings;
    in
    {
      profile = {
        id = mkProfileId id;
        settings = webAppPrefs // effectiveSettings // webAppExtensionPrefs app.addons;
        userChrome = if app.userChrome == null then defaultUserChrome else app.userChrome;
      } // lib.optionalAttrs (app.search != { }) { inherit (app) search; };

      desktopEntry = mkWebAppEntry {
        inherit id;
        inherit (app) name url icon;
        package = mkWebAppPackage {
          inherit id;
          inherit (app) url userscripts;
          policies = effectivePolicies;
        } app.addons;
      };

      assertion = {
        assertion = builtins.pathExists (iconsDir + "/${app.icon}");
        message = "[web-apps] ${id}: missing icon file icons/${app.icon}";
      };
    };
}
