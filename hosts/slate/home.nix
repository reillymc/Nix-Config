{
  pkgs,
  theme,
  ...
}:

{
  imports = [
    ../../modules/home-manager
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "reilly";
  home.homeDirectory = "/home/reilly";

  myhome.display = {
    monitors = [
      {
        output = "DP-1";
        model = "eiq-495KCSUW";
        resolution = "5120x1440";
        refreshRate = 144;
        position = "2256x0";
        scale = 1.0;
        bitdepth = 10;
        isUltrawide = true;
        control = "ddcutil";
      }
      {
        output = "eDP-1";
        model = "LQ135P1JX51";
        resolution = "2256x1504";
        refreshRate = 60;
        position = "0x0";
        scale = 1.0;
        bitdepth = 10;
        control = "brightnessctl";
      }
    ];
    brightness = {
      maxTime = "07:00";
      minTime = "22:45";
    };
    nightShift = {
      clearTime = "07:00";
      shiftTime = "21:30";
    };
  };

  myhome.vscode.enable = true;

  myhome.web-apps = {
    enable = true;
    immich.enable = true;
    jellyfin.enable = true;
    jellyseerr.enable = true;
    messenger.enable = true;
    navidrome.enable = true;
    proton-mail.enable = true;
    youtube.enable = true;
    whatsapp.enable = true;
  };

  myhome.audio.devices = [
    "bluez_output.94_DB_56_D5_A1_18.1" # Bluetooth Headphones
    "alsa_output.pci-0000_00_1f.3.hdmi-stereo" # Speaker via monitor
  ];

  home.pointerCursor = {
    gtk.enable = true;
    hyprcursor.enable = true;
    package = pkgs.bibata-cursors;
    name = if theme == "light" then "Bibata-Modern-Classic" else "Bibata-Modern-Ice";
    size = 16;
  };

  programs.git = {
    settings = {
      user = {
        name = "reillymc";
        email = "reilly@mackenzie-cree.net";
      };
      core = {
        editor = "code --wait"; # Todo: make configurable
      };
      credential = {
        helper = "store";
      };
      help = {
        autocorrect = "prompt";
      };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/<user>/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
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
