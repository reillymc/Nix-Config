{
  lib,
  config,
  options,
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
    ./scripts.nix
  ];

  options.mynixos.myUnfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of unfree package names to allow";
  };

  options.mynixos.configDir = lib.mkOption {
    type = lib.types.path;
    default = "/etx/nixos";
    description = "Path to configuration location. Used for utility scripts and resources.";
  };

  config.nixpkgs.config.allowUnfreePredicate =
    let
      allowedUnfreePackages =
        config.mynixos.myUnfreePackages
        ++ (
          if options ? home-manager && options.home-manager ? users then
            lib.concatMap (user: (user.myhome or { }).myUnfreePackages or [ ]) (
              lib.attrValues config.home-manager.users
            )
          else
            [ ]
        );
    in
    pkg: builtins.elem (lib.getName pkg) allowedUnfreePackages;
}
