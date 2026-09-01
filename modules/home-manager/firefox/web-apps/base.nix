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

  # Deterministic moz-extension:// UUID for an addon ID. Extensions map
  # their host UUID in the `extensions.webextensions.uuids' pref; pinning it
  # keeps `storage/default/moz-extension+++<uuid>/' stable across profile
  # regeneration so persisted extension data survives reboots.
  mkUuid =
    addonId:
    let
      hex = builtins.hashString "sha256" addonId;
    in
    lib.concatStringsSep "-" [
      (builtins.substring 0 8 hex)
      (builtins.substring 8 4 hex)
      (builtins.substring 12 4 hex)
      (builtins.substring 16 4 hex)
      (builtins.substring 20 12 hex)
    ];

  webappPolicies = import ./policies.nix;
  prefs = import ../prefs;
  webAppSingleMinimal = (import ../user-chrome).webAppSingleMinimal;

  # New Tab Override is force-installed in every webapp (via ExtensionSettings)
  # and configured through managed storage (3rdparty policy).
  newTabOverrideId = "newtaboverride@agenedia.com";
  newTabOverrideSlug = "new-tab-override";

  # UUID pinning pref: keeps moz-extension UUIDs stable across profile
  # regeneration so the persisted extension data under
  # `storage/default/moz-extension+++<uuid>/' survives reboots.
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

  # ExtensionSettings enterprise policy following the NixOS wiki pattern:
  # lock the binary to the declared addons and force-install them from AMO
  # (latest.xpi, fetches once per fresh profile), updates disabled so the
  # pinned Nix-installed versions are never silently replaced.
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

  webAppIcons = pkgs.stdenv.mkDerivation {
    name = "webapp-icons";
    src = ./icons;
    installPhase = ''
      mkdir -p $out/share/icons/webapps
      cp -r * $out/share/icons/webapps/
    '';
  };

  # Per-webapp Firefox binary. Enterprise policies are per-binary
  # (distribution/policies.json), so each webapp launches its own wrapped
  # Firefox carrying the shared webapp baseline merged with the app's own
  # `policies' overrides, the generated ExtensionSettings, and the New Tab
  # Override managed-storage config (3rdparty policy -> browser.storage.managed,
  # which the addon treats as authoritative). Identical policy sets share one
  # wrapper derivation.
  mkWebAppPackage =
    app: extraAddons:
    let
      appPolicies = app.policies or { };
    in
    pkgs.firefox.override (old: {
      extraPolicies =
        (old.extraPolicies or { })
        // webappPolicies.webAppPolicies
        // appPolicies
        // {
          ExtensionSettings =
            (mkWebAppExtensionSettings extraAddons) // (appPolicies.ExtensionSettings or { });
          "3rdparty" = {
            Extensions = ((appPolicies."3rdparty" or { }).Extensions or { }) // {
              ${newTabOverrideId} = {
                type = "custom_url";
                url = app.url;
              };
            };
          };
        };
    });

  mkWebAppEntry =
    app:
    let
      pkg = app.package or pkgs.firefox;
    in
    {
      inherit (app) name;
      type = "Application";
      exec = "${pkg}/bin/firefox -no-remote --profile \"${config.xdg.configHome}/mozilla/firefox/${app.id}\" --class \"${app.id}\" --name \"${app.name}\" --new-window \"${app.url}\"";
      icon = "${webAppIcons}/share/icons/webapps/${app.icon}";
      categories = [ "X-Internet" ];
      settings = {
        Keywords = "WebApp";
        StartupWMClass = app.id;
      };
    };

  # Factory for a web app module: one attrset generates the per-app enable
  # option, the wrapped per-webapp Firefox binary, the profile (settings +
  # userChrome), and the XDG desktop entry. Apps simply call this with their
  # `id'/'name'/'url' and optional addons/settings/userChrome/policies.
  mkWebAppModule =
    {
      id,
      name,
      url,
      icon ? "${id}.svg",
      addons ? [ ],
      settings ? { },
      userChrome ? null,
      policies ? { },
    }:
    {
      options.myhome.web-apps.${id}.enable = lib.mkEnableOption "${name} web app";

      config = lib.mkIf config.myhome.web-apps.${id}.enable {
        programs.firefox.profiles.${id} = {
          id = mkProfileId id;
          settings = prefs.webApp // settings // webAppExtensionPrefs addons;
          userChrome = if userChrome == null then webAppSingleMinimal else userChrome;
        };

        xdg.desktopEntries.${id} = mkWebAppEntry {
          inherit
            id
            name
            url
            icon
            ;
          package = mkWebAppPackage { inherit id url policies; } addons;
        };

        assertions = [
          {
            assertion = builtins.pathExists "${./icons}/${icon}";
            message = "[web-apps] ${id}: missing icon file icons/${icon}";
          }
        ];
      };
    };
in
{
  inherit
    mkWebAppEntry
    mkProfileId
    mkUuid
    mkWebAppPackage
    mkWebAppModule
    webAppExtensionPrefs
    ;
}
