{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
let
  schedule = config.mynixos.theme.schedule;
  isScheduled = schedule.lightTime != null && schedule.darkTime != null;

  determineTheme = ''
    determine_theme() {
      local requested_theme="''${1:-}"

      if [[ "$requested_theme" == light || "$requested_theme" == dark ]]; then
        echo "$requested_theme"
        return
      fi

      ${
        if isScheduled then
          ''
            local current
            current=$(date +%H%M)
            current=$((10#$current))

            local start="${schedule.lightTime}"
            local end="${schedule.darkTime}"

            start="''${start/:/}"
            end="''${end/:/}"

            start=$((10#$start))
            end=$((10#$end))

            if (( current >= start && current < end )); then
              echo light
            else
              echo dark
            fi
          ''
        else
          ''
            # No theme schedule on this host; dark is the only theme.
            echo dark
          ''
      }
    }
  '';

  switchCommand =
    if isScheduled then
      ''
        theme=$(determine_theme "''${2:-}")

        if [[ "$theme" == light ]]; then
          nixos-rebuild "$action" \
            --flake ${config.mynixos.configDir}#${hostname} \
            --specialisation light
        else
          nixos-rebuild "$action" \
            --flake ${config.mynixos.configDir}#${hostname}
        fi
      ''
    else
      ''
        if [[ -n "''${2:-}" ]]; then
          echo "This host has no theme schedule; omit the theme argument." >&2
          exit 1
        fi

        nixos-rebuild "$action" \
          --flake ${config.mynixos.configDir}#${hostname}
      '';

  system-build = pkgs.writeShellApplication {
    name = "${hostname}-build";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.nixos-rebuild
    ];

    text = ''
      set -euo pipefail

      if [[ "$EUID" -ne 0 ]]; then
        exec sudo "$0" "$@"
      fi

      ${determineTheme}

      action="''${1:-test}"

      case "$action" in
        switch|test)
          ${switchCommand}
          ;;
        boot)
          if [[ -n "''${2:-}" ]]; then
            echo "boot does not support theme specialisations." >&2
            exit 1
          fi

          nixos-rebuild boot \
            --flake ${config.mynixos.configDir}#${hostname}
          ;;
        *)
          echo "Usage: $0 [switch|test|boot] [light|dark]" >&2
          exit 1
          ;;
      esac
    '';
  };

  system-update = pkgs.writeShellApplication {
    name = "${hostname}-update";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.nix
      pkgs.nvd
    ];

    text = ''
      set -euo pipefail

      flake=${config.mynixos.configDir}
      host=${hostname}

      ${determineTheme}

      nix flake update --flake "$flake"

      theme=$(determine_theme)

      rm -f "$flake/result"
      nix build "$flake#nixosConfigurations.$host.config.system.build.toplevel" \
        --out-link "$flake/result"

      system="$flake/result"
      if [[ "$theme" == light ]]; then
        system="$flake/result/specialisation/light"
      fi

      current=$(readlink -f /run/current-system)
      new=$(readlink -f "$system")

      if [[ "$current" == "$new" ]]; then
        echo "System closure is already up to date"
        exit 0
      fi

      nvd diff "$current" "$new"

      echo
      if [[ -t 0 ]]; then
        read -r -p "Apply this update with ${hostname}-build (test)? [y/N] " answer
        case "$answer" in
          [yY] | [yY][eE][sS])
            "${hostname}-build" test
            exit 0
            ;;
        esac
      fi

      echo "Run '${hostname}-build' to apply the update."
    '';
  };

  system-theme = pkgs.writeShellApplication {
    name = "${hostname}-theme";

    runtimeInputs = [
      pkgs.coreutils
    ];

    text = ''
      set -euo pipefail

      if [[ "$EUID" -ne 0 ]]; then
        exec sudo "$0" "$@"
      fi

      ${determineTheme}

      theme=$(determine_theme "''${1:-}")

      case "$theme" in
        light)
          system="/nix/var/nix/profiles/system/specialisation/light"
          ;;
        dark)
          system="/nix/var/nix/profiles/system"
          ;;
        *)
          echo "Invalid theme: $theme" >&2
          exit 1
          ;;
      esac

      "$system/bin/switch-to-configuration" switch
    '';
  };

  system-clean = pkgs.writeShellApplication {
    name = "${hostname}-clean";

    runtimeInputs = [
      pkgs.nix
    ];

    text = ''
      set -euo pipefail

      sudo nix-collect-garbage --delete-older-than 30d
      nix-collect-garbage --delete-older-than 30d
      nix store optimise
    '';
  };

in
{
  environment.systemPackages = [
    system-clean
    system-build
    system-update
  ]
  ++ lib.optionals isScheduled [ system-theme ];
}
