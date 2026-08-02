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
    seerr.enable = true;
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
    lmstudio
    (writeShellApplication {
      name = "moveMusic";

      runtimeInputs = [
        pkgs.rsgain
      ];

      text = ''
        set -euo pipefail

        rsgain easy /home/reilly/Downloads/Music\ Queue -m MAX
        scp -r /home/reilly/Downloads/Music\ Queue/* hupboard:/media/red/media/music/queue/ && rm -r ~/Downloads/Music\ Queue/*
      '';
    })
  ];

  home.persistence."/persist" = {
    hideMounts = true;
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
      ".config/bruno"
      ".config/Code"
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
      ".local/share"
      ".local/state/news-flash"
      ".local/state/nix"
      ".local/state/showtime"
      ".ollama"
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".steam"
      ".var"
      ".vscode-shared"
    ];
    files = [
      ".git-credentials"
      ".vscode/argv.json"
      ".bash_history"
      ".npmrc"
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

  systemd.user.services.bluetooth-autoconnect = {
    Unit = {
      Description = "Auto-connect Bluetooth headphones";

      Wants = [
        "graphical-session.target"
        "wireplumber.service"
      ];

      After = [
        "graphical-session.target"
        "wireplumber.service"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";

      ExecStart = pkgs.writeShellScript "bt-connect" ''
        set -euo pipefail

        # Trigger PipeWire/WirePlumber socket activation if needed.
        ${pkgs.wireplumber}/bin/wpctl status >/dev/null 2>&1 || true

        # Wait up to 15 seconds for WirePlumber.
        for _ in $(seq 30); do
          if systemctl --user is-active --quiet wireplumber.service; then
            break
          fi
          sleep 0.5
        done

        echo "Attempting to connect headphones..."

        exec ${pkgs.bluez}/bin/bluetoothctl connect 94:DB:56:D5:A1:18
      '';
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
