{
  lib,
}:
# `rec' because `mkStateOptions' and `mkBackup' compose the helpers below.
rec {
  backupEntryType = lib.types.submodule {
    options = {
      enable = (lib.mkEnableOption "backing up this state entry") // {
        default = true;
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Paths or glob patterns excluded from this entry's backup. Patterns
          not starting with `/` are resolved against the entry path; `/...'
          (anchored) and `!...' (negation) patterns are passed to restic
          verbatim.

          Only meaningful for directory entries: restic does not apply
          excludes to sources passed to it explicitly, so a pattern here can
          never affect a `file' entry.
        '';
      };
    };
  };

  # Turns an entry into an impermanence submodule: the path under its own key,
  # plus the forwarded `persist' options. `kind' is passed rather than inferred
  # so the list the entry came from decides the path key.
  toImpermanence = kind: e: if lib.isString e then e else e.persist // { ${kind} = e.${kind}; };

  filterMarked = es: lib.filter (e: lib.isString e || e.backup.enable) es;

  statePath = e: if lib.isString e then e else (e.directory or e.file);

  entryExcludes =
    resolve: es:
    lib.concatMap (
      e:
      if lib.isString e then
        [ ]
      else
        map (
          p:
          if lib.hasPrefix "/" p || lib.hasPrefix "!" p then p else "${lib.removeSuffix "/" (resolve e)}/${p}"
        ) e.backup.exclude
    ) es;

  mkExcludeOnFileAssertion =
    {
      option,
      files,
    }:
    let
      offenders = lib.filter (e: !lib.isString e && e.backup.exclude != [ ]) files;
    in
    {
      assertion = offenders == [ ];
      message = ''
        restic never applies excludes to sources passed to it explicitly, so
        `backup.exclude' has no effect on these ${option} file entries:

        ${lib.concatStringsSep "\n" (lib.map statePath offenders)}
      '';
    };

  # Builds the `myhome.state' / `mynixos.state' options and assertions. Each
  # side writes its own impermanence wiring in its `state/default.nix';
  # `mkBackup' below builds the backup options.
  mkStateOptions =
    {
      prefix,
      pathDescription,
      entryNoun,
    }:
    {
      config,
      ...
    }:
    let
      cfg = config.${prefix}.state;

      entryType =
        kind:
        lib.types.either lib.types.str (
          lib.types.submodule {
            options = {
              ${kind} = lib.mkOption {
                type = lib.types.str;
                description = pathDescription;
              };

              persist = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = { };
                description = ''
                  Impermanence options for this entry (e.g. `mode', `user', `group',
                  `hideMount', `allowTrash'), forwarded verbatim. Every entry is
                  persisted.
                '';
              };

              backup = lib.mkOption {
                type = backupEntryType;
                default = { };
                description = ''
                  Backup options for this entry. `enable' (default `true') controls
                  whether this entry is included in `${prefix}.state.backup';
                  `exclude' lists paths or globs under it to skip.
                '';
              };
            };
          }
        );

    in
    {
      options.${prefix}.state = {
        persist = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = ''
            Store-level impermanence options (e.g. `persistentStoragePath',
            `hideMounts', `allowTrash', `enable') forwarded to the host's
            persistence store. `persistentStoragePath' defaults to `"/persist"'.
            The impermanence module must be imported for this to take effect.
          '';
        };

        directories = lib.mkOption {
          type = lib.types.listOf (entryType "directory");
          default = [ ];
          description = ''
            Directories to persist via impermanence and back up via
            `${prefix}.state.backup'.

            Paths are ${entryNoun}. Each entry is either a string path or an
            attribute set accepting `directory', `persist', and `backup'.
          '';
        };

        files = lib.mkOption {
          type = lib.types.listOf (entryType "file");
          default = [ ];
          description = ''
            Files to persist via impermanence and back up via
            `${prefix}.state.backup'.

            Paths are ${entryNoun}. Each entry is either a string path or an
            attribute set accepting `file', `persist', and `backup'.
          '';
        };
      };

      config.assertions = [
        (mkExcludeOnFileAssertion {
          option = "${prefix}.state";
          inherit (cfg) files;
        })
      ];
    };

  # Shared `myhome.state.backup' / `mynixos.state.backup' wiring. Kept here so
  # the two sides cannot drift. `home' (Home Manager only) resolves entries
  # under `$HOME' and enables the `~/Projects' build-output excludes; without
  # it, entries are used verbatim as absolute paths (NixOS).
  mkBackup =
    {
      prefix,
      home ? null,
    }:
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.${prefix}.state.backup;
      state = config.${prefix}.state;

      # Baked restic defaults. `home' is only set by the Home Manager side,
      # which is the only one with a `~/Projects' tree to exclude build output
      # from.
      baked = {
        initialize = true;

        pruneOpts = [
          "--keep-daily 14"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 20"
          "--quiet"
        ];

        # Backblaze free egress is 3x stored/month; a random 3.33% of packs per
        # day reads ~1x/month (~64% of packs verified in 30 days, ~95% in 90)
        # and uses 33% of free egress relative to the repo size monthly.
        checkOpts = [
          "--read-data-subset=3.33%"
        ];

        timerConfig = {
          OnCalendar = "*-*-* 08:00:00";
          Persistent = true;
        };
      }
      // lib.optionalAttrs (home != null) {
        # Only unambiguous build output. `lib' and `bin' are ordinary source
        # directory names in most projects, so they are never excluded here.
        exclude = [
          "${home}/Projects/**/node_modules"
          "${home}/Projects/**/.expo"
          "${home}/Projects/**/.svelte-kit"
          "${home}/Projects/**/dist"
          "${home}/Projects/**/target"
          "${home}/Projects/**/logs"
        ];
      };

      marked = filterMarked (state.directories ++ state.files);

      resolve = e: if home != null then "${home}/${statePath e}" else statePath e;

      backupPaths = lib.unique (map resolve marked);

      # The list-valued keys are appended to the baked lists instead of
      # replacing them. restic evaluates `exclude' patterns in order (so `!'
      # negations must come last) and `forget' overwrites each retention policy
      # as it reads it (so a later `--keep-*' wins).
      listKeys = [
        "exclude"
        "pruneOpts"
      ];

      settings =
        (removeAttrs baked listKeys)
        // (removeAttrs cfg.settings ([ "paths" ] ++ listKeys))
        // {
          pruneOpts = baked.pruneOpts ++ (cfg.settings.pruneOpts or [ ]);
          exclude = lib.unique (
            (baked.exclude or [ ]) ++ entryExcludes resolve marked ++ (cfg.settings.exclude or [ ])
          );
        };
    in
    {
      options.${prefix}.state.backup = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = ''
            Whether to enable restic backups of `${prefix}.state' entries.
          '';
        };

        settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = ''
            Options forwarded verbatim to `services.restic.backups.daily' (e.g.
            `repositoryFile', `passwordFile', `environmentFile', `repository',
            `passwordCommand'). Baked defaults set `initialize = true',
            `pruneOpts', `checkOpts', and `timerConfig'. Keys
            set here override the corresponding baked default; the list-valued
            `pruneOpts' and `exclude' are appended to the baked lists rather
            than replacing them, so a caller can widen retention or exclusions
            but not drop a baked entry. `paths' is derived from
            `${prefix}.state' and is always forced; `exclude' additionally
            merges each entry's `backup.exclude'.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = backupPaths != [ ];
            message = ''
              ${prefix}.state.backup is enabled but there is nothing to back
              up. Every state entry is backed up unless `backup.enable =
              false'.
            '';
          }
        ];

        services.restic.backups.daily = settings // {
          paths = backupPaths;
        };
      };
    };
}
