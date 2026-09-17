{
  inputs,
  pkgs,
  config,
  ...
}:
let
  mynixos = {
    steam.enable = true;
    hyprland.enable = true;
    nautilus.enable = true;
    spotify = {
      enable = true;
      adblock.enable = true;
    };
    hardware.logitech = {
      enable = true;
      device.mx4.enable = true;
    };
    via.enable = true;
    utilities.iosSideloaderEnv.enable = true;
    ly.enable = true;
    theme.schedule = {
      lightTime = "07:00";
      darkTime = "19:00";
    };
    configDir = "/home/reilly/Projects/Nix-Config";

    # Unfree packages that need to be allowed
    unfreePackages = [
      "obsidian"
    ];
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/nixos/default.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/microvm/host.nix
    ../../modules/nixos/microvm/microvm.nix
    ./secrets.nix
  ];

  hardware.enableRedistributableFirmware = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [
    "amd_pstate=guided"
    "amdgpu.gpu_recovery=1"
  ];
  boot.initrd.systemd.enable = true;
  boot.loader.timeout = 1;
  systemd.network.wait-online.enable = false;

  boot.initrd.luks.devices."luks-42d04de4-1b56-431b-b6e8-21277e8b3e94".device =
    "/dev/disk/by-uuid/42d04de4-1b56-431b-b6e8-21277e8b3e94";

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.i2c.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.persistence.main = {
    persistentStoragePath = "/persist";
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh" # Retain keys used for agenix
      "/var/lib/bluetooth"
      "/var/lib/microvms"
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

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id == "org.freedesktop.login1.suspend" &&
        subject.user == "reilly"
      ) {
        return polkit.Result.YES;
      }
    });
  '';

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;
    users = {
      reilly = {
        isNormalUser = true;
        createHome = true;
        hashedPasswordFile = config.age.secrets."reilly/password".path;
        description = "Reilly MacKenzie-Cree";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
      guest = {
        isNormalUser = true;
        createHome = true;
        hashedPasswordFile = config.age.secrets."guest/password".path;
      };
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
      "reilly" = import ./home/reilly.nix;
      "guest" = import ./home/guest.nix;
    };
  };
  inherit mynixos;

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    bluez
    papers
    vlc
    pwvucontrol
    libnotify
    sshfs
    comma
    nil
  ];

  services.logind.settings.Login.HandlePowerKey = "lock";

  services.udev.extraRules = ''
    # Disable wakeup for all USB devices
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"

    # Re-enable NuPhy receiver
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3247", ATTR{power/wakeup}="enabled"

    # Create stable symlinks for GPU cards so AQ_DRM_DEVICES can reference them
    # Integrated GPU (Granite Ridge) -> /dev/dri/amd-igpu
    KERNEL=="card*", KERNELS=="0000:0e:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
    # Discrete GPU (Navi 48) -> /dev/dri/amd-dgpu
    KERNEL=="card*", KERNELS=="0000:03:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-dgpu"
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

  programs.localsend.enable = true;
  programs.nix-index.enable = true;

  networking.firewall.checkReversePath = false; # Currently required for proton vpn to work

  # Allow ssh from the tailnet only
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 22 ];

  # Allow the dev-server ports forwarded by VS Code directly to host
  # to be reachable over the tailnet
  networking.firewall.interfaces."tailscale0".allowedTCPPortRanges = [
    {
      from = 3000;
      to = 3002;
    }
    {
      from = 8080;
      to = 8082;
    }
  ];

  # services.llama-cpp = {
  #   enable = true;
  #   package = pkgs.llama-cpp.override {
  #     cudaSupport = false;
  #     rocmSupport = true;
  #     metalSupport = false;
  #     blasSupport = true;
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
