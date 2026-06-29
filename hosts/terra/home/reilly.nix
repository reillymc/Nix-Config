{
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/home-manager
    ./common.nix
    ../../../users/reilly.nix
  ];

  myhome.vscode.enable = true;

  myhome.web-apps = {
    enable = true;
    immich.enable = true;
    jellyfin.enable = true;
    jellyseerr.enable = true;
    messenger.enable = true;
    navidrome.enable = true;
    paperless.enable = true;
    proton-mail.enable = true;
    youtube.enable = true;
    whatsapp.enable = true;
  };

  programs.zed-editor.enable = true;

  home.packages = with pkgs; [
    newsflash
    picard
    foliate
    libreoffice
    obsidian
    proton-vpn
    prismlauncher
    rapidraw
    opencode
    gocryptfs
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
