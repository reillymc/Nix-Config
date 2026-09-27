{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/utilities/docker.nix
    ./secrets.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.dev = import ./home.nix;

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "mist";

  system.stateVersion = "26.05";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    hostKeys = [
      {
        path = "/var/lib/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/var/lib/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # To match (host)
  users.groups.dev = {
    gid = 1000;
  };

  users.users.dev = {
    isNormalUser = true;
    group = "dev";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy53djcTOJHEZ0EPXS2pMGrbRf45URABcm/VKSD18u8 reilly@systems"
    ];
  };

  users.mutableUsers = false;
  users.allowNoPasswordLogin = false;

  services.resolved.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.tempAddresses = "disabled";
  systemd.network.networks."10-e" = {
    matchConfig.Name = "e*";
    addresses = [ { Address = "192.168.83.6/24"; } ];
    routes = [ { Gateway = "192.168.83.1"; } ];
  };
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    max-jobs = 2;
    cores = 2;
  };
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  systemd.settings.Manager = {
    # fast shutdowns/reboots! https://mas.to/@zekjur/113109742103219075
    DefaultTimeoutStopSec = "30s";
  };

  # Inotify limits for hot-reload tooling (webpack, watchers, etc.)
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 1024;

  # zram swap as an OOM safety net for build spikes.
  # swappiness 10 keeps swap as pure overflow.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50; # Adjust based on how much RAM to allocate for compressed swap
  boot.kernel.sysctl."vm.swappiness" = 10;

  mynixos.docker.enable = true;

  systemd.services.docker.serviceConfig.TimeoutStopSec = "30s";

  programs.nix-ld.enable = true; # Required for vscode-server to work
  programs.zsh.enable = true; # Required for vscode-server to work

  environment.systemPackages = with pkgs; [
    git
    curl
    openssh
    nixd
    nixfmt
    ghostty.shell_integration
    ghostty.terminfo
  ];
}
