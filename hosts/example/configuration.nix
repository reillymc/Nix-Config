{
  inputs,
  ...
}:
let
  mynixos = {
    hyprland.enable = true;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/default.nix
    ../../modules/nixos/common.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.example-user = {
    isNormalUser = true;
    description = "Example User";
  };

  specialisation.light.configuration = {
    home-manager.extraSpecialArgs.theme = "light";
  };
  specialisation.dark.configuration = {
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs mynixos;
      theme = "dark";
      configDir = "<repo directory>";
    };
    users = {
      "example-user" = import ./home.nix;
    };
  };

  inherit mynixos;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
