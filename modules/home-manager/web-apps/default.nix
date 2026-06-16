{
  lib,
  pkgs,
  config,
  ...
}:
let
  base = import ./base.nix {
    inherit
      lib
      pkgs
      config
      ;
  };

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

  apps = map (
    path:
    import path {
      inherit
        pkgs
        config
        lib
        base
        ;
    }
  ) appModules;

  # Collect all profile names
  profiles = lib.flatten (
    map (app: lib.attrNames (app.config.programs.firefox.profiles or { })) apps
  );

  # Compute IDs
  profileIds = builtins.listToAttrs (
    map (p: {
      name = p;
      value = base.mkProfileId p;
    }) profiles
  );

  # Detect duplicate IDs (collision)
  idToNames = lib.foldl' (
    acc: name:
    let
      id = profileIds.${name};
      old = acc.${toString id} or [ ];
    in
    acc // { ${toString id} = old ++ [ name ]; }
  ) { } (lib.attrNames profileIds);

  collisions = lib.filterAttrs (_: v: builtins.length v > 1) idToNames;

  _ = lib.assertMsg (collisions == { }) ''
    [web-apps] Collision detected in generated Firefox profile IDs!
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        id: names: "ID ${id} used by profiles: ${lib.concatStringsSep ", " names}"
      ) collisions
    )}
  '';
in
{
  imports = appModules;

  options = {
    myhome.web-apps.enable = lib.mkEnableOption "Enable Firefox-based Web Apps integration";
  };

  config = lib.mkIf config.myhome.web-apps.enable {
    programs.firefox.enable = true;
  };
}
