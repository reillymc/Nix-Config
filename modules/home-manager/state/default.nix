# User state persisted via impermanence and backed up via restic.
{
  config,
  lib,
  ...
}:
let
  stateLib = import ../../../lib/state.nix { inherit lib; };
  cfg = config.myhome.state;

  absolutePaths = lib.filter (lib.hasPrefix "/") (
    map stateLib.statePath (cfg.directories ++ cfg.files)
  );
in
{
  imports = [
    ./backup.nix
    (stateLib.mkStateOptions {
      prefix = "myhome";
      pathDescription = "Path relative to `home.homeDirectory'.";
      entryNoun = "relative to `home.homeDirectory'";
    })
  ];

  # Only define the store when state is actually used, so hosts without
  # impermanence and without state stay unaffected.
  config = lib.mkIf (cfg.persist != { } || cfg.directories != [ ] || cfg.files != [ ]) {
    assertions = [
      {
        assertion = absolutePaths == [ ];
        message = ''
          myhome.state entries must be relative to `home.homeDirectory';
          absolute paths belong to `mynixos.state':

          ${lib.concatStringsSep "\n" absolutePaths}
        '';
      }
    ];

    home.persistence.main = {
      persistentStoragePath = lib.mkDefault "/persist";
    }
    // cfg.persist
    // {
      directories = map (stateLib.toImpermanence "directory") cfg.directories;
      files = map (stateLib.toImpermanence "file") cfg.files;
    };
  };
}
