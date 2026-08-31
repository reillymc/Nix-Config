{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.myhome.persistence;
in
{
  options.myhome.persistence = {
    persistentStoragePath = lib.mkOption {
      type = lib.types.path;
      default = "/persist";
      description = ''
        The path to persistent storage backing the user's `home.persistence.main'
        store. Override per host if persistent storage lives elsewhere.
      '';
    };

    hideMounts = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to hide the persisted bind mounts from showing up as mounted drives.";
    };

    allowTrash = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow newer GIO-based applications to trash files in persisted directories.";
    };

    directories = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
      description = ''
        Paths relative to the user's home directory that should be persisted.
        Modules append to this list; the collected paths are merged into the
        user's `home.persistence.main' store (if impermanence is used).
        Entries are passed through to impermanence, so impermanence directory
        attribute sets (e.g. mode/user overrides) are also accepted.
      '';
    };

    files = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
      description = ''
        Files relative to the user's home directory that should be persisted.
        Modules append to this list; the collected files are merged into the
        user's `home.persistence.main' store (if impermanence is used).
        Entries are passed through to impermanence, so impermanence file
        attribute sets are also accepted.
      '';
    };
  };

  config = lib.mkIf ((options.home.persistence or null) != null) {
    home.persistence.main = {
      inherit (cfg)
        directories
        files
        hideMounts
        allowTrash
        persistentStoragePath
        ;
    };
  };
}
