{
  lib,
  config,
  ...
}:
let
  appModules = [
    ./apps/immich.nix
    ./apps/jellyfin.nix
    ./apps/seerr.nix
    ./apps/messenger.nix
    ./apps/navidrome.nix
    ./apps/paperless.nix
    ./apps/proton-mail.nix
    ./apps/youtube.nix
    ./apps/whatsapp.nix
  ];

  profiles = config.programs.firefox.profiles;

  profileNames = lib.attrNames (lib.filterAttrs (name: _: name != "default") profiles);

  idToNames = lib.foldl' (
    acc: name:
    let
      id = toString profiles.${name}.id;
      old = acc.${id} or [ ];
    in
    acc // { ${id} = old ++ [ name ]; }
  ) { } (lib.attrNames profiles);

  collisions = lib.filterAttrs (_: v: builtins.length v > 1) idToNames;
in
{
  imports = appModules;

  options = {
    myhome.web-apps.enable = lib.mkEnableOption "Enable Firefox-based Web Apps integration";
  };

  config = lib.mkIf config.myhome.web-apps.enable (
    lib.mkMerge [
      {
        programs.firefox.enable = true;

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
        ];
      }
      (
        let
          wholeIds = builtins.filter (id: config.myhome.web-apps.${id}.persistWholeProfile or false) (
            lib.attrNames (lib.removeAttrs config.myhome.web-apps [ "enable" ])
          );
          # Apps opting into full profile retention which is atomic-write safe
          # for Firefox's temp+rename of files like session, extension state etc
          wholeProfiles = builtins.filter (p: builtins.elem p wholeIds) profileNames;
          selectiveProfiles = builtins.filter (p: !builtins.elem p wholeIds) profileNames;
        in
        {
          myhome.persistence.directories =
            map (p: ".config/mozilla/firefox/${p}") wholeProfiles
            ++ map (p: ".config/mozilla/firefox/${p}/storage") selectiveProfiles
            ++ map (p: ".config/mozilla/firefox/${p}/extensions") selectiveProfiles;
          myhome.persistence.files = lib.concatMap (
            p:
            map (f: ".config/mozilla/firefox/${p}/${f}") [
              "cookies.sqlite"
              "storage.sqlite"
              "content-prefs.sqlite"
              "permissions.sqlite"
              "logins.db"
              "key4.db"
              "cert9.db"
            ]
          ) selectiveProfiles;
        }
      )
    ]
  );
}
