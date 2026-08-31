{
  pkgs,
  ...
}:

let
  git-project = pkgs.writeShellApplication {
    name = "git-project";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gawk
    ];

    text = ''
      # git-project: manage a project that uses the git-worktree layout (bare
      # repo + one worktree per branch, forked from "main").

      usage() {
          cat <<'EOF'
      usage: git project <subcommand> [args]

      Manage a project using the git-worktree layout. `<name>/.git` holds the
      bare repository and each branch gets a worktree alongside it at the top
      level (e.g. <name>/main).

      subcommands:
        init <name>                 create a new local project
        clone <url>                 clone an existing project
        branch add <name> [base]    fork a new branch+worktree from base (default: main)
        branch attach <name>        attach a worktree to an existing branch
        branch remove <name> [-f]   remove a worktree and its branch (-f forces)
        branch list                 list worktrees

      options:
        -h, --help                  show this help

      examples:
        git project init my-project
        git project clone git@github.com:user/repo.git
        git project branch add feature/foo
      EOF
          exit 0
      }

      set -euo pipefail

      die() {
          printf 'git project: %s\n' "$*" >&2
          exit 1
      }

      # prints the path of the worktree currently on branch $1
      worktree_of_branch() {
          git worktree list --porcelain |
              awk -v b="$1" '
                  /^worktree / { path = substr($0, 10); next }
                  /^branch / {
                      branch = $0
                      sub(/^branch refs\/heads\//, "", branch)
                      if (branch == b) { print path; exit }
                  }
              '
      }

      # prints the path of the main worktree
      main_worktree() {
          git worktree list --porcelain |
              awk '
                  /^worktree / { path = substr($0, 10); next }
                  /^branch / {
                      if ($0 ~ / refs\/heads\/main$/) { print path; exit }
                  }
              '
      }

      # prints the path of the project root (the bare repository)
      project_root() {
          git worktree list --porcelain |
              awk '
                  /^worktree / { path = substr($0, 10); next }
                  /^bare/ { print path; exit }
              '
      }

      # copy .devcontainer/.env from the main worktree into a new worktree
      copy_env() {
          target="$1"
          src="$(main_worktree)"
          if [ -n "$src" ] && [ -f "$src/.devcontainer/.env" ]; then
              if [ -e "$target/.devcontainer/.env" ]; then
                  printf 'git project: .devcontainer/.env already exists in %s; leaving as-is\n' \
                      "$target" >&2
              else
                  mkdir -p "$target/.devcontainer"
                  cp -p "$src/.devcontainer/.env" "$target/.devcontainer/.env"
                  printf 'git project: copied .devcontainer/.env from %s\n' "$src"
              fi
          else
              printf 'git project: no .devcontainer/.env in the main worktree; skipping\n' >&2
          fi
      }

      cmd_init() {
          name=""
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  -h | --help) usage ;;
                  -*) die "unknown option: $1 (see --help)" ;;
                  *)
                      if [ -z "$name" ]; then
                          name="$1"
                      else
                          die "unexpected argument: $1"
                      fi
                      ;;
              esac
              shift
          done

          [ -n "$name" ] || die "missing <name> (see --help)"
          if [ -e "$name" ]; then die "path already exists: $name"; fi

          printf 'git project: creating bare repository %s/.git\n' "$name"
          git init --bare --initial-branch=main "$name/.git"

          printf 'git project: creating main worktree\n'
          git -C "$name" worktree add --orphan -b main main

          printf 'git project: done. cd %s/main\n' "$name"
      }

      cmd_clone() {
          url=""
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  -h | --help) usage ;;
                  -*) die "unknown option: $1 (see --help)" ;;
                  *)
                      if [ -z "$url" ]; then
                          url="$1"
                      else
                          die "unexpected argument: $1"
                      fi
                      ;;
              esac
              shift
          done

          [ -n "$url" ] || die "missing <url> (see --help)"

          name="$(basename "$url" .git)"
          [ -n "$name" ] || die "could not derive a directory name from <url>"
          if [ -e "$name" ]; then die "path already exists: $name"; fi

          printf 'git project: checking remote default branch\n'
          default_branch="$(git ls-remote --symref "$url" HEAD |
              awk 'NR == 1 && $1 == "ref:" { sub(/^refs\/heads\//, "", $2); print $2 }' ||
              die "could not reach remote: $url")"
          if [ -z "$default_branch" ]; then
              default_branch="unknown"
          fi
          if [ "$default_branch" != "main" ]; then
              die "the remote default branch is '$default_branch'; only 'main'-based repos are supported"
          fi

          printf 'git project: cloning %s into %s/.git\n' "$url" "$name"
          git clone --bare --single-branch "$url" "$name/.git" || die "git clone failed"

          printf 'git project: widening fetch refspec to all branches\n'
          git -C "$name" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

          printf 'git project: fetching all branches\n'
          if ! git -C "$name" fetch origin; then
              rm -rf "$name"
              die "git fetch failed"
          fi

          if ! git -C "$name" rev-parse --verify --quiet refs/heads/main >/dev/null; then
              rm -rf "$name"
              die "the remote default branch is not 'main'; only 'main'-based repos are supported"
          fi

          printf 'git project: creating main worktree\n'
          git -C "$name" worktree add main main

          printf 'git project: done. cd %s/main\n' "$name"
      }

      cmd_branch_add() {
          name=""
          base=""
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  -h | --help) usage ;;
                  -*) die "unknown option: $1 (see --help)" ;;
                  *)
                      if [ -z "$name" ]; then
                          name="$1"
                      elif [ -z "$base" ]; then
                          base="$1"
                      else
                          die "unexpected argument: $1"
                      fi
                      ;;
              esac
              shift
          done

          [ -n "$name" ] || die "missing <name> (see --help)"

          if ! git rev-parse --git-dir >/dev/null 2>&1; then
              die "not inside a git project"
          fi

          root="$(project_root)"
          [ -n "$root" ] || die "could not determine the project root"

          if git show-ref --verify --quiet "refs/heads/$name"; then
              die "branch '$name' already exists; use 'git project branch attach $name'"
          fi

          if [ -e "$root/$name" ]; then die "path already exists: $root/$name"; fi

          if [ -z "$base" ]; then
              base="main"
          fi

          unborn_base=0
          if ! git rev-parse --verify --quiet "$base" >/dev/null 2>&1; then
              # base may be the repo's own unborn HEAD (e.g. main with no
              # commits yet, right after init)
              if [ "$base" = "$(git symbolic-ref --short HEAD 2>/dev/null || true)" ]; then
                  unborn_base=1
              else
                  die "base '$base' not found locally"
              fi
          fi

          if [ "$unborn_base" -eq 1 ]; then
              printf 'git project: creating worktree "%s" as an empty branch (base %s has no commits yet)\n' \
                  "$name" "$base"
              git -C "$root" worktree add --orphan -b "$name" "$name"
          else
              printf 'git project: forking worktree "%s" from "%s"\n' "$name" "$base"
              git -C "$root" worktree add -b "$name" "$name" "$base"
          fi

          copy_env "$root/$name"
          printf 'git project: done. cd %s\n' "$root/$name"
      }

      cmd_branch_attach() {
          name=""
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  -h | --help) usage ;;
                  -*) die "unknown option: $1 (see --help)" ;;
                  *)
                      if [ -z "$name" ]; then
                          name="$1"
                      else
                          die "unexpected argument: $1"
                      fi
                      ;;
              esac
              shift
          done

          [ -n "$name" ] || die "missing <name> (see --help)"

          if ! git rev-parse --git-dir >/dev/null 2>&1; then
              die "not inside a git project"
          fi

          root="$(project_root)"
          [ -n "$root" ] || die "could not determine the project root"

          if git show-ref --verify --quiet "refs/heads/$name"; then
              if [ -e "$root/$name" ]; then die "path already exists: $root/$name"; fi
              printf 'git project: attaching worktree "%s" to branch "%s"\n' "$name" "$name"
              git -C "$root" worktree add "$name" "$name"
          elif git show-ref --verify --quiet "refs/remotes/origin/$name"; then
              if [ -e "$root/$name" ]; then die "path already exists: $root/$name"; fi
              printf 'git project: attaching worktree "%s" to remote branch "origin/%s"\n' "$name" "$name"
              git -C "$root" worktree add -b "$name" "$name" "origin/$name"
          else
              die "neither local branch '$name' nor 'origin/$name' exists"
          fi

          copy_env "$root/$name"
          printf 'git project: done. cd %s\n' "$root/$name"
      }

      cmd_branch_remove() {
          name=""
          force=0
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  -h | --help) usage ;;
                  -f | --force) force=1 ;;
                  -*) die "unknown option: $1 (see --help)" ;;
                  *)
                      if [ -z "$name" ]; then
                          name="$1"
                      else
                          die "unexpected argument: $1"
                      fi
                      ;;
              esac
              shift
          done

          [ -n "$name" ] || die "missing <name> (see --help)"

          if ! git rev-parse --git-dir >/dev/null 2>&1; then
              die "not inside a git project"
          fi

          path="$(worktree_of_branch "$name")"

          if [ "$force" -eq 1 ]; then
              if [ -n "$path" ]; then
                  printf 'git project: force-removing worktree %s\n' "$path"
                  git worktree remove --force "$path"
              else
                  printf 'git project: no worktree on branch %s (already removed?)\n' "$name" >&2
              fi
              if git show-ref --verify --quiet "refs/heads/$name"; then
                  printf 'git project: force-deleting branch %s\n' "$name"
                  git branch -D "$name"
              else
                  printf 'git project: branch %s already gone\n' "$name" >&2
              fi
              printf 'git project: removed %s\n' "$name"
              return 0
          fi

          if [ -z "$path" ]; then
              die "no worktree on branch '$name'"
          fi

          printf 'git project: removing worktree %s\n' "$path"
          if ! git worktree remove "$path"; then
              printf 'git project: could not remove worktree %s; see the git error above.\n' "$path" >&2
              printf 'git project: re-run with -f to force removal.\n' >&2
              exit 1
          fi

          if ! git branch -d "$name"; then
              printf 'git project: branch remove aborted; branch %s has unmerged commits.\n' "$name" >&2
              printf 'git project: re-run with -f to force (drops them).\n' >&2
              exit 1
          fi

          printf 'git project: removed %s\n' "$name"
      }

      cmd_branch_list() {
          if ! git rev-parse --git-dir >/dev/null 2>&1; then
              die "not inside a git project"
          fi

          git worktree list
      }

      cmd_branch() {
          if [ "$#" -eq 0 ]; then
              usage
          fi
          case "$1" in
              add) shift; cmd_branch_add "$@" ;;
              attach) shift; cmd_branch_attach "$@" ;;
              remove) shift; cmd_branch_remove "$@" ;;
              list) shift; cmd_branch_list "$@" ;;
              -h | --help | "") usage ;;
              *) die "unknown branch subcommand: $1 (see --help)" ;;
          esac
      }

      if [ "$#" -eq 0 ]; then
          usage
      fi

      case "$1" in
          init) shift; cmd_init "$@" ;;
          clone) shift; cmd_clone "$@" ;;
          branch) shift; cmd_branch "$@" ;;
          -h | --help | "") usage ;;
          *) die "unknown subcommand: $1 (see --help)" ;;
      esac
    '';
  };
in
{
  home.username = "dev";
  home.homeDirectory = "/home/dev";

  programs.zsh = {
    enable = true;
    history = {
      size = 4000;
      save = 10000000;
      ignoreDups = true;
      share = false;
      append = true;
    };
    initContent = ''
      source ${pkgs.ghostty.shell_integration}/zsh/ghostty-integration
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      _git-project() {
          local -a subs
          subs=(
              'init:create a new local project'
              'clone:clone an existing project'
              'branch:manage worktrees/branches'
          )
          if (( CURRENT == 2 )); then
              _describe -t subcommands 'git project subcommand' subs
              return
          fi
          case ''${words[2]} in
              branch)
                  local -a bsub
                  bsub=(
                      'add:fork a new branch+worktree from a base'
                      'attach:attach a worktree to an existing branch'
                      'remove:remove a worktree and its branch'
                      'list:list worktrees'
                  )
                  if (( CURRENT == 3 )); then
                      _describe -t branch 'branch subcommand' bsub
                      return
                  fi
                  case ''${words[3]} in
                      attach | remove)
                          local -a branches
                          branches=( ''${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null)"} )
                          _describe -t branches 'branch' branches
                          return
                          ;;
                  esac
                  ;;
          esac
          _files
      }
      compdef _git-project git-project
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "reillymc";
        email = "dev@reillymc.com";
      };
      help = {
        autocorrect = "prompt";
      };
      alias.project = "!git-project";
      push.autoSetupRemote = true;
    };
  };

  programs.npm = {
    settings = {
      "ignore-scripts" = true;
      "min-release-age" = 7;
      "min-release-age-exclude" = [ "@reillymc/*" ];
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$username$directory$git_branch$git_status$status$cmd_duration$jobs$time$character";
    };
  };

  home.stateVersion = "26.05";

  home.packages = [ git-project ];

  programs.home-manager.enable = true;

  programs.opencode = {
    enable = true;
    settings = {
      autoupdate = false;
      default_agent = "plan";
      agent = {
        plan = {
          color = "primary";
        };
        build = {
          color = "secondary";
        };
      };
      model = "opencode-go/glm-5.3-flash";
      provider."opencode-go".options.apiKey = "{file:api-key}";
    };
  };

  home.persistence."/var/persist" = {
    hideMounts = true;
    directories = [
      ".expo"
      ".local/share/opencode"
      ".local/state/opencode"
      ".vscode-server"
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
    files = [
      ".zsh_history"
    ];
  };
}
