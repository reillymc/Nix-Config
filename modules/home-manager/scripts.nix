{
  pkgs,
  hostname,
  ...
}:
let
  rebuild-switch = pkgs.writeShellScriptBin "rebuild-switch" ''
    current_time=$(date +%H%M)
    current_time=$((10#$current_time))  # Force base-10

    start=800   # No leading zero
    end=1830

    if [[ "$current_time" -ge "$start" && "$current_time" -le "$end" ]]; then
      specialisation="light"
    else
      specialisation="dark"
    fi

    sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#${hostname} --specialisation "$specialisation"  '';

in
{
  home.packages = [ rebuild-switch ];
}
