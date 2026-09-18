{
  lib,
  pkgs,
  config,
  ...
}:
let
  helpers = import ./lib { inherit lib pkgs config; };
  inherit (helpers) mkAppConfig;

  # NOTE: the submodule below holds pure data only (options, no config).
  appSubmodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "${name} web app";

        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Desktop entry display name.";
        };

        url = lib.mkOption {
          type = lib.types.str;
          description = "App URL. Also the new-tab URL and default homepage.";
        };

        icon = lib.mkOption {
          type = lib.types.str;
          default = "${name}.svg";
          description = "Icon file in icons/ (asserted to exist).";
        };

        addons = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                id = lib.mkOption {
                  type = lib.types.str;
                  description = "Addon's real gecko id (AMO API guid).";
                };
                slug = lib.mkOption {
                  type = lib.types.str;
                  description = "AMO slug, drives the latest.xpi install URL.";
                };
              };
            }
          );
          default = [ ];
          description = "AMO addons to install into the app profile.";
        };

        settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Extra profile prefs (user.js), merged over defaults.";
        };

        userChrome = lib.mkOption {
          type = lib.types.nullOr lib.types.lines;
          default = null;
          description = "Custom userChrome; defaults to webAppSingleMinimal.";
        };

        policies = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Per-binary policy overrides, merged over the baseline.";
        };

        search = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Firefox search config for the profile (force/default/engines); empty disables.";
        };

        grantNotifications = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Pre-grant web notifications for the app origin.";
        };

        savePasswords = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enable password saving for the app. Pair with `persistWholeProfile':
            Firefox writes its login store (`logins.json') atomically, so saved
            logins only survive reboots with whole-profile persistence.
          '';
        };

        persistWholeProfile = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Retain the whole profile dir (saved logins, extension registry, session restore).";
        };

        userscripts = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "Name of the userscript.";
                };
                hosts = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  description = "Hosts the userscript applies to.";
                };
                script = lib.mkOption {
                  type = lib.types.lines;
                  description = "Userscript source.";
                };
              };
            }
          );
          default = [ ];
          description = "Userscripts to install into the app profile.";
        };
      };
    }
  );

  enabledApps = lib.filterAttrs (_: app: app.enable) config.myhome.web-apps.apps;
  appConfigs = lib.mapAttrs mkAppConfig enabledApps;
  wholeIds = lib.attrNames (lib.filterAttrs (_: app: app.persistWholeProfile) enabledApps);
  selectiveIds = lib.attrNames (lib.filterAttrs (_: app: !app.persistWholeProfile) enabledApps);

  webAppIds = lib.mapAttrs (id: _: helpers.mkProfileId id) enabledApps;

  idToNames = lib.foldl' (
    acc: name:
    let
      key = toString webAppIds.${name};
      old = acc.${key} or [ ];
    in
    acc // { ${key} = old ++ [ name ]; }
  ) { } (lib.attrNames enabledApps);

  collisions = lib.filterAttrs (_: v: builtins.length v > 1) idToNames;

  defaultProfileId = config.programs.firefox.profiles.default.id or 0;
  defaultCollisions = lib.filterAttrs (_: id: id == defaultProfileId) webAppIds;
in
{
  options.myhome.web-apps = {
    enable = lib.mkEnableOption "Firefox-based Web Apps integration";

    apps = lib.mkOption {
      type = lib.types.attrsOf appSubmodule;
      default = { };
      description = "Firefox web apps. Built-ins are provided as definitions below (overridable); custom apps can be added.";
    };
  };

  config = lib.mkMerge [
    {
      myhome.web-apps.apps = {
        immich = import ./apps/immich.nix;
        jellyfin = import ./apps/jellyfin.nix;
        messenger = import ./apps/messenger.nix;
        navidrome = import ./apps/navidrome.nix;
        paperless = import ./apps/paperless.nix;
        proton-mail = import ./apps/proton-mail.nix;
        seerr = import ./apps/seerr.nix;
        whatsapp = import ./apps/whatsapp.nix;
        youtube = import ./apps/youtube.nix;
      };
    }
    (lib.mkIf config.myhome.web-apps.enable {
      programs.firefox.enable = true;

      programs.firefox.profiles = lib.mapAttrs (_: c: c.profile) appConfigs;

      xdg.desktopEntries = lib.mapAttrs (_: c: c.desktopEntry) appConfigs;

      assertions = [
        {
          assertion = collisions == { };
          message = ''
            [web-apps] Collision detected in generated Firefox profile IDs!
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                id: names: "ID ${id} used by profiles: ${lib.concatStringsSep ", " names}"
              ) collisions
            )}
          '';
        }
        {
          assertion = defaultCollisions == { };
          message = ''
            [web-apps] Generated profile ID collides with the default profile ID (${toString defaultProfileId}): ${lib.concatStringsSep ", " (lib.attrNames defaultCollisions)}
          '';
        }
      ]
      ++ lib.mapAttrsToList (_: c: c.assertion) appConfigs;

      myhome.state.directories =
        map (p: {
          directory = ".config/mozilla/firefox/${p}";
          backup.enable = false;
        }) wholeIds
        ++ map (p: {
          directory = ".config/mozilla/firefox/${p}/storage";
          backup.enable = false;
        }) selectiveIds
        ++ map (p: {
          directory = ".config/mozilla/firefox/${p}/extensions";
          backup.enable = false;
        }) selectiveIds;
      myhome.state.files = lib.concatMap (
        p:
        map
          (f: {
            file = ".config/mozilla/firefox/${p}/${f}";
            backup.enable = false;
          })
          [
            "cookies.sqlite"
            "storage.sqlite"
            "content-prefs.sqlite"
            "permissions.sqlite"
            "key4.db"
            "cert9.db"
          ]
      ) selectiveIds;
    })
  ];
}
