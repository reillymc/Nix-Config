{
  lib,
  config,
  ...
}:
{
  imports = [
    ./entertainment
    ./gnome
    ./hardware
    ./hyprland
    ./services
    ./theme.nix
    ./utilities
  ];

  options.mynixos.myUnfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of unfree package names to allow";
  };

  config.nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) config.mynixos.myUnfreePackages;
}
