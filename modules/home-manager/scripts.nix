{
  mynixos,
  pkgs,
  hostname,
  configDir,
  ...
}:
let
  determineThemeShell = ''
    determine_theme() {
      local arg="''${1:-}"

      if [[ "$arg" == light || "$arg" == dark ]]; then
        echo "$arg"
        return
      fi

      local current
      current=$(date +%H%M)
      current=$((10#$current))

      local start="${mynixos.theme.schedule.lightTime}"
      local end="${mynixos.theme.schedule.darkTime}"

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

      ${determineThemeShell}

      specialisation=$(determine_theme "''${1:-}")

      sudo nixos-rebuild switch \
        --flake ${configDir}#${hostname} \
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

      nix flake update --flake ${configDir}
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
      sudo nix-collect-garbage --delete-older-than 30d

      echo "Optimising store..."
      nix store optimise
    '';
  };

  system-theme = pkgs.writeShellApplication {
    name = "${hostname}-theme";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];

    text = ''
      set -euo pipefail

      ${determineThemeShell}

      target=$(determine_theme "''${1:-}")

      sudo systemctl start \
        "switchToSystem''${target^}Mode.service"
    '';
  };
in
{
  home.packages = [
    system-rebuild
    system-update
    system-clean
    system-theme
  ];
}
