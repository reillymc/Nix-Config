{
  config,
  pkgs,
  hostname,
  ...
}:
let
  determineThemeSpecialisation = ''
    determine_theme_specialisation() {
      local requested_theme="''${1:-}"

      if [[ "$requested_theme" == light || "$requested_theme" == dark ]]; then
        echo "$requested_theme"
        return
      fi

      local current
      current=$(date +%H%M)
      current=$((10#$current))

      local start="${config.mynixos.theme.schedule.lightTime}"
      local end="${config.mynixos.theme.schedule.darkTime}"

      start="''${start/:/}"
      end="''${end/:/}"

      start=$((10#$start))
      end=$((10#$end))

      if (( current >= start && current < end )); then
        echo light
      else
        echo dark
      fi
    }
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

      ${determineThemeSpecialisation}

      action="''${1:-test}"

      case "$action" in
        switch|test)
          specialisation=$(determine_theme_specialisation "''${2:-}")

          nixos-rebuild "$action" \
            --flake ${config.mynixos.configDir}#${hostname} \
            --specialisation "$specialisation"
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
      pkgs.nix
    ];

    text = ''
      set -euo pipefail

      nix flake update --flake ${config.mynixos.configDir}
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

      ${determineThemeSpecialisation}

      specialisation=$(determine_theme_specialisation "''${1:-}")

      case "$specialisation" in
        light|dark) ;;
        *) echo "Invalid theme: $specialisation" >&2; exit 1 ;;
      esac

      "/nix/var/nix/profiles/system/specialisation/''${specialisation}/bin/switch-to-configuration" switch
    '';
  };

  system-clean = pkgs.writeShellApplication {
    name = "${hostname}-clean";

    runtimeInputs = [
      pkgs.nix
    ];

    text = ''
      set -euo pipefail

      echo "Removing old generations..."
      nix-collect-garbage --delete-older-than 30d

      echo "Optimising store..."
      nix store optimise
    '';
  };

in
{
  environment.systemPackages = [
    system-clean
    system-build
    system-theme
    system-update
  ];
}
