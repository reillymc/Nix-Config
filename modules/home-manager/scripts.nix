{
  mynixos,
  pkgs,
  hostname,
  configDir,
  ...
}:
let
  system-rebuild = pkgs.writeShellScriptBin "${hostname}-rebuild" ''
    set -euo pipefail

    arg="''${1:-}"

    if [[ "$arg" == "light" || "$arg" == "dark" ]]; then
        specialisation="$arg"
    else
      current_time=$(date +%H%M)
      current_time=$((10#$current_time))  # Force base-10

      light_time="${mynixos.theme.schedule.lightTime}"
      dark_time="${mynixos.theme.schedule.darkTime}"

      start=''${light_time/:/}
      end=''${dark_time/:/}

      start=$((10#$start))
      end=$((10#$end))

      if [[ "$current_time" -ge "$start" && "$current_time" -le "$end" ]]; then
        specialisation="light"
      else
        specialisation="dark"
      fi
    fi

    sudo nixos-rebuild switch \
      --flake ${configDir}#${hostname} \
      --specialisation "$specialisation"
  '';

  system-update = pkgs.writeShellScriptBin "${hostname}-update" ''
    set -euo pipefail
    nix flake update --flake ${configDir}
    echo "Flake inputs updated."
  '';

  system-clean = pkgs.writeShellScriptBin "${hostname}-clean" ''
    set -euo pipefail

    echo "Removing old generations..."
    sudo nix-collect-garbage --delete-older-than 30d

    echo "Optimising store..."
    nix store optimise
  '';
in
{
  home.packages = [
    system-rebuild
    system-update
    system-clean
  ];
}
