{
  hostName,
  ipAddress,
  tapId,
  home-manager,
  nixpkgs,
  mac,
}:

{
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  # pkgsUnstable = import nixpkgs-unstable {
  #   inherit system;
  #   config.allowUnfree = true;
  # };
in
{
  imports = [ home-manager.nixosModules.home-manager ];

  # home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # home-manager.extraSpecialArgs = { inherit configfiles stapelbergnix; };

  # # Claude Code CLI (from nixpkgs-unstable, unfree)
  # environment.systemPackages = [
  #   pkgsUnstable.claude-code
  # ];
  networking.hostName = hostName;

  system.stateVersion = "26.05";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
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

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy53djcTOJHEZ0EPXS2pMGrbRf45URABcm/VKSD18u8 reilly@systems"
    ];
  };

  users.allowNoPasswordLogin = true;

  services.resolved.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.tempAddresses = "disabled";
  systemd.network.enable = true;
  systemd.network.networks."10-e" = {
    matchConfig.Name = "e*";
    addresses = [ { Address = "${ipAddress}/24"; } ];
    routes = [ { Gateway = "192.168.83.1"; } ];
  };
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # Disable firewall for faster boot and less hassle;
  # we are behind a layer of NAT anyway.
  networking.firewall.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

  systemd.settings.Manager = {
    # fast shutdowns/reboots! https://mas.to/@zekjur/113109742103219075
    DefaultTimeoutStopSec = "5s";
  };

  # Inotify limits for hot-reload tooling (webpack, watchers, etc.)
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 1024;

  # Fix for microvm shutdown hang (issue #170):
  # Without this, systemd tries to unmount /nix/store during shutdown,
  # but umount lives in /nix/store, causing a deadlock.
  systemd.mounts = [
    {
      what = "store";
      where = "/nix/store";
      overrideStrategy = "asDropin";
      unitConfig.DefaultDependencies = false;
    }
  ];

  # Use SSH host keys mounted from outside the VM (remain identical).
  # services.openssh.hostKeys = [
  #   {
  #     path = "/etc/ssh/host-keys/ssh_host_ed25519_key";
  #     type = "ed25519";
  #   }
  # ];

  microvm = {
    # Enable writable nix store overlay so nix-daemon works.
    # This is required for home-manager activation.
    # Uses tmpfs by default (ephemeral), which is fine since we
    # don't build anything in the VM.
    writableStoreOverlay = "/nix/.rw-store";

    shares = [
      {
        # use proto = "virtiofs" for MicroVMs that are started by systemd
        proto = "virtiofs";
        tag = "ro-store";
        # a host's /nix/store will be picked up so that no
        # squashfs/erofs will be built for it.
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    interfaces = [
      {
        type = "tap";
        id = tapId;
        mac = mac;
      }
    ];

    hypervisor = "cloud-hypervisor";
    vsock.cid = 5; # matches mac
    vcpu = 8; # 6;
    mem = 12288;
    socket = "control.socket";
  };
}
