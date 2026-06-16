{
  imports = [
    ./development
    ./display
    ./hyprland
    ./options/audio
    ./options/display
    ./options/unfree-packages.nix
    ./utilities
    ./web-apps
  ];

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
