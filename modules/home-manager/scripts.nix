{
  mynixos,
  pkgs,
  hostname,
  configDir,
  ...
}:
let
  rebuild-switch = pkgs.writeShellScriptBin "rebuild-switch" ''
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

    sudo nixos-rebuild switch --flake ${configDir}#${hostname} --specialisation "$specialisation"  '';
in
{
  home.packages = [ rebuild-switch ];
}
