{
  inputs,
  pkgs,
  config,
  ...
}:
let
  metrics = import ../../lib/metrics.nix {
    lib = pkgs.lib;
    inherit pkgs;
  };

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
    healthchecks = {
      enable = true;
      baseUrl = "https://healthchecks.homelab.reillymc.com/ping";
      pingKeyFile = "/run/agenix/healthchecks/ping-key";
      checks = [
        "nix-gc"
        "nix-optimise"
        "fwupd-refresh"
        {
          slug = "disk";
          command = metrics.disk { };
          timer = "*-*-* 09:00:00";
        }
        {
          slug = "failed-units";
          command = metrics.failedUnits;
        }
        {
          slug = "temp";
          command = metrics.temperature {
            sensors = [
              {
                name = "coretemp";
                max = 95;
              }
              {
                name = "nvme";
                max = 85;
              }
            ];
          };
        }
      ];
    };
    configDir = "/home/reilly/Projects/Nix-Config";

    # Unfree packages that need to be allowed
    unfreePackages = [
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
    ../../modules/nixos/default.nix
    ../../modules/nixos/common.nix
    ./secrets.nix
  ];

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

  environment.persistence.main = {
    persistentStoragePath = "/persist";
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh" # Retain keys used for agenix
      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/var/lib/lxc"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/systemd/rfkill"
      "/var/lib/systemd/timers"
      "/var/lib/tailscale"
      "/var/log"
    ];

    files = [
      "/etc/ly/save.txt" # Ly last uses session / user
      "/etc/machine-id"
      "/var/lib/systemd/random-seed"
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.tailscale.enable = true;
  services.flatpak.enable = true;

  users = {
    mutableUsers = false;
    users.reilly = {
      isNormalUser = true;
      createHome = true;
      hashedPasswordFile = config.age.secrets."reilly/password".path;
      description = "Reilly MacKenzie-Cree";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "docker"
        "libvirtd"
      ];
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs mynixos;
      theme = "dark"; # Default, overridden by specialisations
    };
    users = {
      "reilly" = import ./home.nix;
    };
  };

  inherit mynixos;

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    nautilus
    bluez
    xdg-desktop-portal-gtk
    papers
    vlc
    pwvucontrol
    libnotify
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
