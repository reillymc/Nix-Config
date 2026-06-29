{
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
        output = "eDP-1";
        model = "LQ135P1JX51";
        resolution = "2256x1504";
        refreshRate = 60;
        position = "0x0";
        scale = 1.0;
        bitdepth = 10;
        control = "brightnessctl";
      }
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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
