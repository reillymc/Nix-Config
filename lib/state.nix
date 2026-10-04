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
    entries:
    lib.concatMap (
      e:
      map (
        p: if lib.hasPrefix "/" p || lib.hasPrefix "!" p then p else "${lib.removeSuffix "/" e.path}/${p}"
      ) e.exclude
    ) entries;

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

  # Resolves `state.directories'/`state.files' into records shared by the
  # backup and restore modules, so the two cannot drift. `resolve' maps an
  # entry to its live path (default: the path as written); `kind' is
  # "directory" or "file" and `exclude' is `backup.exclude' (empty for string
  # entries).
  mkStateEntries =
    {
      state,
      resolve ? statePath,
    }:
    let
      entry = kind: e: {
        path = resolve e;
        inherit kind;
        exclude = if lib.isString e then [ ] else e.backup.exclude;
      };
    in
    map (entry "directory") (filterMarked state.directories)
    ++ map (entry "file") (filterMarked state.files);

  # Builds the restore command for a consumer to install (Home Manager:
  # `home.packages', NixOS: `environment.systemPackages').
  mkRestoreScript =
    {
      pkgs,
      name,
      persistenceRoot,
      entries,
      user,
    }:
    let
      includesFile = pkgs.writeText "state-restore-includes" (
        lib.concatLines (lib.unique (map (e: e.path) entries))
      );

      entriesFile = pkgs.writeText "state-restore-entries" (
        lib.concatMapStrings (e: "${e.path}\t${e.kind}\n") entries
      );

      systemctlPrefix = if user then "systemctl --user" else "systemctl";

      euidGuard =
        if user then
          ''
            if [[ "$EUID" -eq 0 ]]; then
              echo "error: ${name} must run as your user, not root" >&2
              exit 1
            fi
          ''
        else
          ''
            if [[ "$EUID" -ne 0 ]]; then
              exec sudo "$0" "$@"
            fi
          '';

    in
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.systemd
        pkgs.util-linux
      ];
      text = ''
        set -euo pipefail

        readonly persist_default=${lib.escapeShellArg persistenceRoot}
        readonly includes_file=${lib.escapeShellArg (toString includesFile)}
        readonly entries_file=${lib.escapeShellArg (toString entriesFile)}

        usage() {
          cat >&2 <<'EOF'
        Usage: ${name} [options] [snapshot]

        Restore every backed-up state entry to a snapshot. Files not in the
        snapshot are kept unless --delete is given. No backup is taken first.

        Arguments:
          snapshot          snapshot ID to restore (default: latest for this host)

        Options:
          -l, --list        list snapshots for this host and exit (--all: all hosts)
          -d, --dry-run     show what a restore would change (writes nothing), then exit
          -p, --paths       print the persistence root and each live -> store mapping, exit
          -y, --yes         skip the confirmation prompt
              --all         with --list, list snapshots for all hosts
              --delete      also delete files under the state paths that are not
                            in the snapshot
              --no-delete   keep files not in the snapshot (default)
              --persist-dir DIR
                            restore to DIR instead of the configured persistence root
                            (recovery/live environments; cannot be /)
          -h, --help        show help
        EOF
        }

        ${euidGuard}

        snapshot=""
        persist=""
        mode="restore"
        all=false
        yes=false
        delete=false

        while [[ $# -gt 0 ]]; do
          case "$1" in
            -l | --list) mode="list" ;;
            -d | --dry-run) mode="dry-run" ;;
            -p | --paths) mode="paths" ;;
            -y | --yes) yes=true ;;
            --all) all=true ;;
            --delete) delete=true ;;
            --no-delete) delete=false ;;
            --persist-dir)
              if [[ $# -lt 2 ]]; then
                echo "error: --persist-dir requires a directory" >&2
                exit 2
              fi
              persist="$2"
              shift
              ;;
            -h | --help)
              usage
              exit 0
              ;;
            -*)
              echo "error: unknown option: $1" >&2
              usage
              exit 2
              ;;
            *)
              if [[ -n "$snapshot" ]]; then
                echo "error: unexpected argument: $1" >&2
                exit 2
              fi
              snapshot="$1"
              ;;
          esac
          shift
        done

        delete_args=()
        if [[ "$delete" == true ]]; then
          delete_args+=(--delete)
        fi

        snapshot="''${snapshot:-latest}"
        persist="$(realpath -m -- "''${persist:-$persist_default}")"
        root="$(realpath -m -- "$persist_default")"

        if [[ "$persist" == / ]]; then
          echo "error: refusing to restore to /" >&2
          exit 1
        fi

        if ! command -v restic-daily >/dev/null 2>&1; then
          echo "error: restic-daily is not on PATH (backup wrapper missing)" >&2
          exit 1
        fi

        # --host/--path filters only apply to "latest"; explicit IDs bypass them.
        path_args=()
        if [[ "$snapshot" == latest ]]; then
          path_args=(--host "$(uname -n)")
          while IFS=$'\t' read -r live _kind; do
            path_args+=(--path "$live")
          done < "$entries_file"
        fi

        case "$mode" in
          paths)
            echo "persistence root: $persist"
            while IFS=$'\t' read -r live kind; do
              printf '%s -> %s%s (%s)\n' "$live" "$persist" "$live" "$kind"
            done < "$entries_file"
            exit 0
            ;;
          list)
            if [[ "$all" == true ]]; then
              restic-daily snapshots
            else
              restic-daily snapshots --host "$(uname -n)"
            fi
            exit 0
            ;;
          dry-run)
            # Every per-item restore line is VV (restic verbosity 3), which
            # --verbose=2 enables; keep only file changes and deletions
            # (restic always reports directories and symlinks as restored).
            # if-changed stats size+mtime so large binary trees are not hashed
            # on every preview.
            echo "dry run: no files will be written; showing what a restore of $snapshot to $persist would change" >&2
            set +e
            restic-daily restore "$snapshot" \
              --target "$persist" \
              "''${delete_args[@]}" \
              --dry-run --verbose=2 --overwrite if-changed \
              "''${path_args[@]}" \
              --include-file "$includes_file" \
              | awk '
                  $0 ~ /^restored[[:space:]]/ && $0 !~ / with size / { next }
                  /^unchanged[[:space:]]/ { next }
                  /^(restored|updated|deleted)[[:space:]]/ { changed++; print; next }
                  { print }
                  END { exit (changed > 0 ? 0 : 3) }
                '
            pipeline_status=("''${PIPESTATUS[@]}")
            set -e
            if [[ "''${pipeline_status[0]}" -ne 0 ]]; then
              exit "''${pipeline_status[0]}"
            fi
            if [[ "''${pipeline_status[1]}" -eq 3 ]]; then
              echo "warning: no changes; the store already matches this snapshot (or the include root is absent)." >&2
            fi
            exit 0
            ;;
        esac

        if [[ "$persist" == "$root" ]]; then
          if [[ ! -d "$persist" ]]; then
            echo "error: $persist does not exist; is the persistence store mounted?" >&2
            exit 1
          fi

          mounted="$(findmnt -n -r -o TARGET --target "$persist")"
          if ! grep -qxF -- "$persist" <<<"$mounted"; then
            echo "error: $persist is not a mounted filesystem (found $mounted); refusing to restore through the root filesystem" >&2
            exit 1
          fi

          while IFS=$'\t' read -r live kind; do
            store="$persist$live"
            if [[ "$kind" == file ]]; then
              target="$(dirname -- "$store")"
            else
              target="$store"
            fi
            if [[ ! -e "$target" ]]; then
              echo "error: store path $target does not exist; has impermanence created it?" >&2
              exit 1
            fi
            if ! live_id="$(stat -Lc '%d:%i' -- "$live" 2>/dev/null)"; then
              echo "error: $live does not exist; run a system activation first" >&2
              exit 1
            fi
            store_id="$(stat -Lc '%d:%i' -- "$store" 2>/dev/null || true)"
            if [[ "$live_id" != "$store_id" ]]; then
              echo "error: $live is not backed by $store; remount or reboot before restoring" >&2
              exit 1
            fi
          done < "$entries_file"
        fi

        trap '${systemctlPrefix} start restic-backups-daily.timer || true' EXIT

        ${systemctlPrefix} stop restic-backups-daily.timer

        service_state="$(${systemctlPrefix} show -p ActiveState --value restic-backups-daily.service 2>/dev/null || true)"
        case "$service_state" in
          active | activating | reloading | refreshing | deactivating)
            echo "error: restic-backups-daily.service is already running; wait for it to finish" >&2
            exit 1
            ;;
        esac

        echo "warning: this tool does not create a backup; create a rollback point manually if you need one." >&2
        echo "warning: close applications and log out of the affected session before continuing." >&2

        if [[ "$yes" != true ]]; then
          echo "snapshot: $snapshot"
          echo "persistence root: $persist"
          echo "included paths:"
          while IFS=$'\t' read -r live _kind; do
            echo "  $live"
          done < "$entries_file"

          answer=""
          if ! read -r -p "Restore $snapshot to $persist? [y/N] " answer; then
            echo "aborted" >&2
            exit 1
          fi
          case "$answer" in
            [yY] | [yY][eE][sS]) ;;
            *)
              echo "aborted" >&2
              exit 1
              ;;
          esac
        fi

        restore_args=(--target "$persist" --include-file "$includes_file" "''${delete_args[@]}" "''${path_args[@]}")

        status=0
        restic-daily restore "$snapshot" "''${restore_args[@]}" || status=$?
        exit "$status"
      '';
    };

  # Shared `myhome.state.backup' / `mynixos.state.backup' wiring. Kept here so
  # the two sides cannot drift. Callers pass the resolved state entries and any
  # extra restic excludes they need (Home Manager adds its `~/Projects'
  # build-output patterns).
  mkBackup =
    {
      prefix,
      entries,
      extraExcludes ? [ ],
    }:
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.${prefix}.state.backup;

      backupPaths = lib.unique (map (e: e.path) entries);

      # Baked restic defaults.
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
      };

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
          exclude = lib.unique (extraExcludes ++ entryExcludes entries ++ (cfg.settings.exclude or [ ]));
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
