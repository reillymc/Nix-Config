{
  config,
  pkgs,
  hostname,
  ...
}:
let
  determineThemeSpecialisation = ''
    determine_theme_specialisation() {
      local arg="''${1:-}"

      if [[ "$arg" == light || "$arg" == dark ]]; then
        echo "$arg"
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

      if (( current >= start && current <= end )); then
        echo light
      else
        echo dark
      fi
    }
  '';

  system-rebuild = pkgs.writeShellApplication {
    name = "${hostname}-rebuild";

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

      specialisation=$(determine_theme_specialisation "''${1:-}")

      nixos-rebuild switch \
        --flake ${config.mynixos.configDir}#${hostname} \
        --specialisation "$specialisation"
    '';
  };

  system-test = pkgs.writeShellApplication {
    name = "${hostname}-test";

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

      specialisation=$(determine_theme_specialisation "''${1:-}")

      nixos-rebuild test \
        --flake ${config.mynixos.configDir}#${hostname} \
        --specialisation "$specialisation"
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
    system-rebuild
    system-test
    system-theme
    system-update
  ];
}
