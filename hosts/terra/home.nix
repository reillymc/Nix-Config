{
  pkgs,
  theme,
  ...
}:

{
  imports = [
    ../../modules/home-manager/default.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "reilly";
  home.homeDirectory = "/home/reilly";

  myhome.vscode.enable = true;
  myhome.hyprland.enable = true;
  myhome.rclone.remote = "b2-terra-crypt";
  myhome.rclone.filter = ''
    # Exclude
    - .obsidian/
    - .expo/
    - .svelte-kit/
    - target/debug/
    - .next/
    - node_modules/
    - dist/
    - lib/
    - bin/Debug/
    - bin/Release/
    - target/debug/
    - target/release/
    - logs/

    # Include
    + /Documents/**
    + /Music/
    + /Pictures/**
    + /Projects/**
    + /Resources/**
    + /Templates/**
    + /Videos/**
    + /.ssh/**

    # Exclude everything else
    - *
  '';

  home.pointerCursor = {
    gtk.enable = true;
    hyprcursor.enable = true;
    package = pkgs.bibata-cursors;
    name = if theme == "light" then "Bibata-Modern-Classic" else "Bibata-Modern-Ice";
    size = 16;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
