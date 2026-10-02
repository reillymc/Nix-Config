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
    ./healthchecks.nix
    ./hyprland
    ./services
    ./state
    ./theme.nix
    ./utilities
    ./scripts.nix
  ];

  options.mynixos.unfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of unfree package names to allow";
  };

  options.mynixos.configDir = lib.mkOption {
    type = lib.types.path;
    default = "/etc/nixos";
    internal = true;
    description = "Path to this repo's checkout; used by the rebuild/update wrappers.";
  };

  config.nixpkgs.config.allowUnfreePredicate =
    let
      allowedUnfreePackages =
        config.mynixos.unfreePackages
        ++ (
          if options ? home-manager && options.home-manager ? users then
            lib.concatMap (user: (user.myhome or { }).unfreePackages or [ ]) (
              lib.attrValues config.home-manager.users
            )
          else
            [ ]
        );
    in
    pkg: builtins.elem (lib.getName pkg) allowedUnfreePackages;
}
