{
  inputs,
  pkgs,
  hostname,
  ...
}:
let
  mynixos = {
    steam.enable = true;
    hyprland.enable = true;
    docker.enable = true;
    firewall.commonPorts.enable = true;
    nautilus.enable = true;
    rclone.enable = true;
    spotify = {
      enable = true;
      adblock.enable = true;
    };
    hardware.logitech = {
      enable = true;
      device.m720.enable = true;
    };
    services.paperless = {
      enable = true;
      backupDir = "/home/reilly/Resources/Backups/Paperless";
      openPort = true;
    };
    utilities.iosSideloaderEnv.enable = true;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/default.nix
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-42d04de4-1b56-431b-b6e8-21277e8b3e94".device =
    "/dev/disk/by-uuid/42d04de4-1b56-431b-b6e8-21277e8b3e94";
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
    extraGroups = [
      "networkmanager"
      "docker" # TODO: manage within docker module
      "wheel"
    ];
  };

  specialisation.light.configuration = {
    home-manager.extraSpecialArgs.theme = "light";
  };
  specialisation.dark.configuration = {
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs mynixos hostname;
      theme = "dark";
      configDir = "/home/reilly/Projects/Nix-Config";
    };
    users = {
      "reilly" = import ./home.nix;
    };
  };

  services.displayManager.gdm.enable = true;

  mynixos = mynixos;

  environment.systemPackages = with pkgs; [
    nautilus
    bluez
    xdg-desktop-portal-gtk
    bruno
    papers
    newsflash
    picard
    foliate
    libreoffice
    vlc
    via
    obsidian
    pwvucontrol
    ddcutil
    libnotify
    sshfs
    protonvpn-gui
  ];

  services.udev.packages = with pkgs; [
    via
  ];

  services.logind.settings.Login.HandlePowerKey = "suspend";

  # M720 and USB hub wake from suspend
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="3247", ATTR{power/wakeup}="enabled"
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTRS{idVendor}=="1a40", ATTRS{idProduct}=="0101", ATTR{power/wakeup}="enabled"
  '';

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  programs.localsend.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };
  nix.optimise.automatic = true;

  systemd.services.switchToDarkMode = {
    description = "Switch to dark mode theme";
    serviceConfig = {
      ExecStart = "/nix/var/nix/profiles/system/specialisation/dark/bin/switch-to-configuration switch";
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.services.switchToLightMode = {
    description = "Switch to light mode theme";
    serviceConfig = {
      ExecStart = "/nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch";
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.switchToDarkMode = {
    description = "Timer to switch to dark mode";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 18:30:00";
      Persistent = true;
    };
  };

  systemd.timers.switchToLightMode = {
    description = "Timer to switch to light mode";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 08:00:00";
      Persistent = true;
    };
  };

  systemd.services.switchToDarkModeNonRoot = {
    description = "Switch to dark mode theme";
    serviceConfig = {
      ExecStart = "hyprctl setcursor Bibata-Modern-Ice 24";
      Type = "oneshot";
    };
  };

  systemd.services.switchToLightModeNonRoot = {
    description = "Switch to light mode theme";
    serviceConfig = {
      ExecStart = "hyprctl setcursor Bibata-Modern-Classic 24";
      Type = "oneshot";
    };
  };

  systemd.timers.switchToDarkModeNonRoot = {
    description = "Timer to switch to dark mode";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 18:30:00";
      Persistent = true;
    };
  };

  systemd.timers.switchToLightModeNonRoot = {
    description = "Timer to switch to light mode";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 08:00:00";
      Persistent = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
