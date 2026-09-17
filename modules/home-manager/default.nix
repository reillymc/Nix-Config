{
  imports = [
    ./audio
    ./development
    ./display
    ./hyprland
    ./unfree-packages.nix
    ./firefox
    ./state
    ./utilities
  ];

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    myhome.state.directories = [
      {
        directory = ".local/state/nix";
        backup.enable = false;
      }
    ];
  };
}
