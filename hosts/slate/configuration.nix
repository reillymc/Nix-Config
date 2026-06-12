{
  inputs,
  pkgs,
  hostname,
  config,
  ...
}:
let
  mynixos = {
    steam.enable = true;
    hyprland.enable = true;
    docker.enable = true;
    nautilus.enable = true;
    spotify = {
      enable = true;
      adblock.enable = true;
    };
    hardware.logitech = {
      enable = true;
      device.mx4.enable = true;
    };
    utilities.iosSideloaderEnv.enable = true;
    ly.enable = true;
    theme.schedule = {
      lightTime = "07:00";
      darkTime = "19:00";
    };

    # Unfree packages that need to be allowed
    myUnfreePackages = [
      "obsidian"
      "broadcom-bt-firmware"
      "b43-firmware"
      "xow_dongle-firmware"
      "facetimehd-calibration"
      "facetimehd-firmware"
      "xone-dongle-firmware"
    ];
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/default.nix
    ./secrets.nix
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  hardware.enableRedistributableFirmware = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 8;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "intel_lpss"
    "intel_lpss_pci"
    "pinctrl_tigerlake"
    "surface_hid"
    "hid_generic"
    "surface_aggregator"
    "surface_hid_core"
    "surface_aggregator_registry"
    "surface_aggregator_hub"
    "8250_dw"
  ];
  boot.kernelModules = [ "i2c-dev" ];
  boot.loader.timeout = 1;
  systemd.network.wait-online.enable = false;

  networking.hostName = hostname;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.auto-optimise-store = true;

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.i2c.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    # hardware.graphics since NixOS 24.11
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  i18n.inputMethod.enable = false;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.tailscale.enable = true;
  services.fwupd.enable = true;
  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.reilly = {
    isNormalUser = true;
    description = "Reilly MacKenzie-Cree";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "docker"
      "libvirtd"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs mynixos hostname;
      theme = "dark"; # Default, overridden by specialisations
      configDir = "/home/reilly/Projects/Nix-Config";
    };
    users = {
      "reilly" = import ./home.nix;
    };
  };

  inherit mynixos;

  environment.systemPackages = with pkgs; [
    nautilus
    bluez
    xdg-desktop-portal-gtk
    papers
    newsflash
    picard
    foliate
    # libreoffice
    vlc
    obsidian
    pwvucontrol
    libnotify
    proton-vpn
    stow # remove
    adwaita-icon-theme # clean up etc
    libinput
    libinput-gestures
    iptsd
    wtype
    comma
    lutris
  ];

  programs.nix-index.enable = true;

  services.logind.settings.Login.HandlePowerKey = "suspend";

  # M720 and USB hub wake from suspend
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="enabled"
  '';

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = false;
    settings = {
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [ "reilly" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  services.restic.backups = {
    daily = {
      initialize = true;
      environmentFile = config.age.secrets."restic-backup/env".path;
      repositoryFile = config.age.secrets."restic-backup/repo".path;
      passwordFile = config.age.secrets."restic-backup/password".path;

      paths = [
        "${config.users.users.reilly.home}/.local/share/Steam/steamapps/compatdata"
        "${config.users.users.reilly.home}/.ssh"
        "${config.users.users.reilly.home}/Documents"
        "${config.users.users.reilly.home}/Games"
        "${config.users.users.reilly.home}/Music"
        "${config.users.users.reilly.home}/Pictures"
        "${config.users.users.reilly.home}/Projects"
        "${config.users.users.reilly.home}/Resources"
        "${config.users.users.reilly.home}/Videos"
      ];

      exclude = [
        "${config.users.users.reilly.home}/.local"
        "${config.users.users.reilly.home}/Downloads"
        "${config.users.users.reilly.home}/Projects/**/node_modules"
        "${config.users.users.reilly.home}/Projects/**/.expo"
        "${config.users.users.reilly.home}/Projects/**/.svelte-kit"
        "${config.users.users.reilly.home}/Projects/**/dist"
        "${config.users.users.reilly.home}/Projects/**/lib"
        "${config.users.users.reilly.home}/Projects/**/bin"
        "${config.users.users.reilly.home}/Projects/**/target"
        "${config.users.users.reilly.home}/Projects/**/logs"
      ];

      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 20"
      ];

      checkOpts = [
        "--read-data-subset=5G"
      ];
    };
  };

  systemd.services.restic-backups-daily.unitConfig.OnFailure =
    "notify-failed-restic-backups-daily.service";
  systemd.services.restic-backups-daily.unitConfig.OnSuccess =
    "notify-success-restic-backups-daily.service";

  systemd.services."notify-failed-restic-backups-daily" = {
    serviceConfig.Type = "oneshot";
    script = "${pkgs.curl}/bin/curl https://healthchecks.homelab.reillymc.com/ping/5a5f523e-97f8-4256-9672-defe69f4d0c5/fail";
  };

  systemd.services."notify-success-restic-backups-daily" = {
    serviceConfig.Type = "oneshot";
    script = "${pkgs.curl}/bin/curl https://healthchecks.homelab.reillymc.com/ping/5a5f523e-97f8-4256-9672-defe69f4d0c5";
  };

  services.power-profiles-daemon.enable = false;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "never";
    };
  };

  programs.localsend.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };

  services.libinput.enable = true;
  services.iptsd = {
    enable = true;
    config = {
      Contacts = {
        ActivationThreshold = 8; # Lower from default 24 (more sensitive)
        DeactivationThreshold = 4; # Lower from default 20 (maintains drag contact)
      };
    };
  };

  environment.etc."libinput/local-overrides.quirks".text = pkgs.lib.mkForce ''
    [Touchpad Overrides]
    MatchUdevType=touchpad
    MatchName=*Microsoft Surface 045E:09AF Touchpad*
    AttrPressureRange=1:0
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  networking.firewall = {
    enable = true;
    # Allow access to development ports over tailscale
    interfaces."tailscale0".allowedTCPPortRanges = [
      {
        from = 8000;
        to = 8002;
      }
      {
        from = 3000;
        to = 3002;
      }
    ];
    checkReversePath = false; # Currently required for proton vpn to work
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
