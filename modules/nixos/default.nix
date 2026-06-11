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
  ];

  options.mynixos.myUnfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of unfree package names to allow";
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
