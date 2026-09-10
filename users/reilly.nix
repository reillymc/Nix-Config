{
  pkgs,
  ...
}:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "reilly";
  home.homeDirectory = "/home/reilly";

  myhome.vscode.enable = true;

  myhome.web-apps = {
    enable = true;
    apps.immich.enable = true;
    apps.jellyfin.enable = true;
    apps.seerr.enable = true;
    apps.messenger.enable = true;
    apps.navidrome.enable = true;
    apps.paperless.enable = true;
    apps.proton-mail.enable = true;
    apps.youtube.enable = true;
    apps.whatsapp.enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = true;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      silverserver = {
        IdentityFile = "~/.ssh/silverserver";
        User = "reilly";
        HostName = "silverserver";
      };

      hupboard = {
        IdentityFile = "~/.ssh/hupboard";
        User = "reilly";
        HostName = "hupboard";
        SetEnv = {
          TERM = "xterm-256color";
        };
      };
    };
  };

  programs.zed-editor.enable = true;

  home.packages = with pkgs; [
    newsflash
    obsidian
    picard
    proton-vpn
    foliate
    rapidraw
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

  myhome.persistence = {
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
      ".config/goa-1.0"
      ".config/libreoffice"
      ".config/MusicBrainz"
      ".config/news-flash"
      ".config/obsidian"
      ".config/spotify"
      ".config/vlc"
      {
        directory = ".gnupg";
        mode = "0700";
      }
      ".local/share/com.github.johnfactotum.Foliate"
      ".local/share/flatpak"
      ".local/share/news-flash"
      ".local/share/org.localsend.localsend_app"
      ".local/share/Steam"
      ".local/share/Trash"
      ".local/state/news-flash"
      ".local/state/showtime"
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".steam"
      ".var"
    ];
    files = [
      ".bash_history"
    ];
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications =
      let
        textEditor = [ "dev.zed.Zed.desktop" ];
        fileManager = [ "org.gnome.Nautilus.desktop" ];
        pdfViewer = [ "org.gnome.Papers.desktop" ];
        audioPlayer = [ "org.gnome.Decibels.desktop" ];
        videoPlayer = [ "vlc.desktop" ];
        imageViewer = [ "org.gnome.Loupe.desktop" ];
      in
      {
        "application/atom+xml" = textEditor;
        "application/pdf" = pdfViewer;
        "application/sql" = textEditor;
        "application/vnd.ms-publisher" = textEditor;
        "application/x-shellscript" = textEditor;
        "application/xml" = textEditor;
        "application/zip" = fileManager;
        "audio/mpeg" = audioPlayer;
        "image/avif" = imageViewer;
        "image/gif" = imageViewer;
        "image/heic" = imageViewer;
        "image/heif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/jpg" = imageViewer;
        "image/png" = imageViewer;
        "image/tiff" = imageViewer;
        "image/webp" = imageViewer;
        "text/x-log" = textEditor;
        "video/mp4" = videoPlayer;
        "video/quicktime" = videoPlayer;
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
}
