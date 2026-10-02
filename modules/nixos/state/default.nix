# System state persisted via impermanence and backed up via restic.
{
  config,
  lib,
  ...
}:
let
  stateLib = import ../../../lib/state.nix { inherit lib; };
  cfg = config.mynixos.state;
in
{
  imports = [
    ./backup.nix
    (stateLib.mkStateOptions {
      prefix = "mynixos";
      pathDescription = "Absolute path.";
      entryNoun = "absolute paths";
    })
  ];

  # Only define the store when state is actually used, so hosts without
  # impermanence and without state stay unaffected.
  config = lib.mkIf (cfg.persist != { } || cfg.directories != [ ] || cfg.files != [ ]) {
    environment.persistence.main = {
      persistentStoragePath = lib.mkDefault "/persist";
    }
    // cfg.persist
    // {
      directories = map (stateLib.toImpermanence "directory") cfg.directories;
      files = map (stateLib.toImpermanence "file") cfg.files;
    };
  };
}
