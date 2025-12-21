{
  config,
  lib,
  ...
}:

{
  imports = [
    ./development
    ./display
    ./hyprland
    ./options/audio
    ./options/display
    ./options/unfree-packages.nix
    ./scripts.nix
    ./utilities
    ./web-apps
  ];

  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) config.myhome.myUnfreePackages;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
