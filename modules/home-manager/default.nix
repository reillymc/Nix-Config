{
  config,
  lib,
  ...
}:

{
  imports = [
    ./options/display
    ./options/audio
    ./options/unfree-packages.nix
    ./development
    ./hyprland
    ./utilities
    ./web-apps
    ./theme.nix
    ./display-brightness.nix
    ./scripts.nix
  ];

  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) config.myhome.myUnfreePackages;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
