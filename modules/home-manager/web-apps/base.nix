{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Stable 32-bit numeric ID derived from the profile name to avoid manually tracking profile IDs
  mkProfileId =
    name:
    let
      hex = builtins.hashString "sha1" name;
      shortHex = builtins.substring 0 8 hex;
      id = lib.fromHexString shortHex; # Convert hex to decimal
    in
    id;

  webAppIcons = pkgs.stdenv.mkDerivation {
    name = "webapp-icons";
    src = ./icons;
    installPhase = ''
      mkdir -p $out/share/icons/webapps
      cp -r * $out/share/icons/webapps/
    '';
  };

  webAppSettings = {
    "browser.tabs.inTitlebar" = 1; # Ensure tabs are drawn in the titlebar if needed
    "browser.window.decorations" = true; # Ensure decorations are enabled (if needed)
    "browser.shell.checkDefaultBrowser" = false;
    "browser.fullscreen.autohide" = false;
    "browser.uidensity" = 1; # minimal ui
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "toolkit.legacyUserProfileCustomizations.windowIcon" = true;
    "browser.aboutConfig.showWarning" = false;

    # Preferences to force links that open in new tabs to open in new windows
    "browser.link.open_newwindow" = 2; # Open links in a new window
    "browser.link.open_newwindow.restriction" = 0; # No restrictions, force open in new window
    "browser.tabs.loadDivertedInBackground" = false; # Ensure links open in the foreground
    "permissions.default.desktop-notification" = 1; # Allow notifications
    "browser.toolbars.bookmarks.visibility" = "never";
  };

  userChromeMinimal = ''
    #navigator-toolbox {
      visibility: collapse !important;
      min-height: 0 !important;
    }

    :root:has(#tabbrowser-tabs tab:nth-of-type(2)) #navigator-toolbox {
      visibility: visible !important;
    }
  '';

  mkWebAppEntry = app: {
    name = app.name;
    type = "Application";
    exec = "${pkgs.firefox}/bin/firefox -no-remote --profile \"${config.xdg.configHome}/mozilla/firefox/${app.id}\" --class \"${app.id}\" --name \"${app.name}\" --new-window \"${app.url}\"";
    icon = "${webAppIcons}/share/icons/webapps/${app.icon}";
    categories = [ "X-Internet" ];
    settings = {
      Keywords = "WebApp";
      StartupWMClass = app.id;
    };
  };
in
{
  inherit
    webAppSettings
    userChromeMinimal
    mkWebAppEntry
    mkProfileId
    ;
}
