{
  ...
}:

{
  imports = [
    ../../modules/home-manager
    ../../users/reilly.nix

  ];

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
    seerr.enable = true;
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

  programs.zed-editor.enable = true;

  home.persistence.main = {
    persistentStoragePath = "/persist";
    hideMounts = true;
    allowTrash = true;
    directories = [
      "Desktop"
      "Documents"
      "Downloads"
      "Games"
      "Music"
      "Pictures"
      "Projects"
      "Public"
      "Resources"
      "Videos"
      ".cache/rofi3.druncache"
      ".config/Code"
      ".config/git/credentials"
      ".config/goa-1.0"
      ".config/kdeconnect"
      ".config/libreoffice"
      ".config/mozilla"
      ".config/MusicBrainz"
      ".config/news-flash"
      ".config/obsidian"
      ".config/spotify"
      ".config/vlc"
      ".config/zed"
      ".expo"
      {
        directory = ".gnupg";
        mode = "0700";
      }
      ".local/share/com.github.johnfactotum.Foliate"
      ".local/share/flatpak"
      ".local/share/keyrings"
      ".local/share/news-flash"
      ".local/share/org.localsend.localsend_app"
      ".local/share/Steam"
      ".local/share/Trash"
      ".local/state/news-flash"
      ".local/state/nix"
      ".local/state/showtime"
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".steam"
      ".var"
      ".vscode-shared"
    ];
    files = [
      ".bash_history"
      ".local/share/wallpaper-dark"
      ".local/share/wallpaper"
      ".npmrc"
      ".vscode/argv.json"
    ];
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "application/x-shellscript" = [ "dev.zed.Zed.desktop" ];
      "application/zip" = [ "org.gnome.Nautilus.desktop" ];
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
      "application/atom+xml" = [ "dev.zed.Zed.desktop" ];
      "audio/mpeg" = [ "org.gnome.Decibels.desktop" ];
      "application/sql" = [ "dev.zed.Zed.desktop" ];
      "application/xml" = [ "dev.zed.Zed.desktop" ];
      "video/quicktime" = [ "vlc.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "text/x-log" = [ "dev.zed.Zed.desktop" ];
      "application/vnd.ms-publisher" = [ "dev.zed.Zed.desktop" ];
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
