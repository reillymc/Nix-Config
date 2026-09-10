{
  lib,
  pkgs,
  config,
  ...
}:
let
  ids = import ./ids.nix { inherit lib; };
  extensions = import ./extensions.nix { inherit lib; inherit (ids) mkUuid; };
  icons = import ./icons.nix { inherit pkgs; };
  autoconfig = import ./autoconfig.nix { inherit pkgs; };
  packageLib = import ./package.nix {
    inherit lib pkgs;
    inherit (extensions) mkWebAppExtensionSettings newTabOverrideId;
    inherit (autoconfig) mkWebAppAutoconfig;
    baselinePolicies = (import ../policies.nix).webAppPolicies;
  };
  entryLib = import ./desktop-entry.nix {
    inherit config pkgs;
    inherit (icons) webAppIcons;
  };
  appLib = import ./app.nix {
    inherit lib;
    inherit (ids) mkProfileId;
    inherit (extensions) webAppExtensionPrefs originOfUrl;
    inherit (packageLib) mkWebAppPackage;
    inherit (entryLib) mkWebAppEntry;
    webAppPrefs = (import ../../prefs).webApp;
    defaultUserChrome = (import ../../user-chrome).webAppSingleMinimal;
    iconsDir = ../icons;
  };
in
{
  inherit (ids) mkProfileId mkUuid;
  inherit (extensions)
    webAppExtensionPrefs
    mkWebAppExtensionSettings
    originOfUrl
    newTabOverrideId
    newTabOverrideSlug
    ;
  inherit (autoconfig) mkWebAppAutoconfig;
  inherit (packageLib) mkWebAppPackage;
  inherit (entryLib) mkWebAppEntry;
  inherit (appLib) mkAppConfig;
}
