# User state persisted via impermanence and backed up via restic.
{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.myhome.state;

  persistEntryType = lib.types.submodule {
    freeformType = lib.types.attrsOf lib.types.anything;

    options.enable = (lib.mkEnableOption "impermanence for this state entry") // {
      default = true;
    };
  };

  backupEntryType = lib.types.submodule {
    options.enable = (lib.mkEnableOption "backing up this state entry") // {
      default = true;
    };
  };

  entryType =
    kind:
    lib.types.either lib.types.str (
      lib.types.submodule {
        options = {
          ${kind} = lib.mkOption {
            type = lib.types.str;
            description = "Path relative to `home.homeDirectory'.";
          };

          persist = lib.mkOption {
            type = persistEntryType;
            default = { };
            description = ''
              Impermanence options for this entry (e.g. `mode', `user', `group',
              `hideMount', `allowTrash'), forwarded verbatim. `enable' (default
              `true') controls whether this entry is persisted.
            '';
          };

          backup = lib.mkOption {
            type = backupEntryType;
            default = { };
            description = ''
              Backup options for this entry. `enable' (default `true') controls
              whether this entry is included in `myhome.state.backup'.
            '';
          };
        };
      }
    );

  stripMarkers =
    e:
    if lib.isString e then
      e
    else
      let
        kind = if e ? directory then "directory" else "file";
      in
      { ${kind} = e.${kind}; } // removeAttrs e.persist [ "enable" ];

  persisted = es: lib.filter (e: lib.isString e || e.persist.enable) es;
in
{
  imports = [ ./backup.nix ];

  options.myhome.state = {
    persist = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Store-level impermanence options forwarded verbatim to
        `home.persistence.main' (`persistentStoragePath', `hideMounts',
        `allowTrash', `enable', ...). `persistentStoragePath' defaults to
        `"/persist"'.
      '';
    };

    directories = lib.mkOption {
      type = lib.types.listOf (entryType "directory");
      default = [ ];
      description = ''
        Directories (relative to `home.homeDirectory') to persist via
        impermanence and back up via `myhome.state.backup'.

        Each entry is either a path string or an attribute set accepting
        `directory', `persist', and `backup'.
      '';
    };

    files = lib.mkOption {
      type = lib.types.listOf (entryType "file");
      default = [ ];
      description = ''
        Files (relative to `home.homeDirectory') to persist via impermanence
        and back up via `myhome.state.backup'.

        Each entry is either a path string or an attribute set accepting
        `file', `persist', and `backup'.
      '';
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = lib.all (e: lib.isString e || e.persist.enable || e.backup.enable) (
            cfg.directories ++ cfg.files
          );
          message = ''
            A myhome.state entry with both `persist.enable = false' and
            `backup.enable = false' is a no-op.
          '';
        }
      ];
    }

    (lib.mkIf ((options.home.persistence or null) != null) {
      home.persistence.main = {
        persistentStoragePath = "/persist";
      }
      // cfg.persist
      // {
        directories = map stripMarkers (persisted cfg.directories);
        files = map stripMarkers (persisted cfg.files);
      };
    })
  ];
}
