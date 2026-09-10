{
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/home-manager
    ../../../users/reilly.nix
    ./common.nix
  ];

  myhome.ssh-mist.enable = true;

  programs.ssh.settings.slate = {
    IdentityFile = "~/.ssh/slate";
    User = "reilly";
    HostName = "slate";
  };

  home.packages = with pkgs; [
    libreoffice
    prismlauncher
    gocryptfs
  ];

  myhome.persistence.directories = [
    ".config/bruno"
    ".local/share/io.github.CyberTimon.RapidRAW"
    ".local/share/PrismLauncher"
    ".local/share/Terraria"
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
