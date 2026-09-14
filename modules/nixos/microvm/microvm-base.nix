{
  hostConfig,
  tapId,
  mac,
  mem ? 12288,
  vcpu ? 8,
  vsockCid ? 5,
}:
{
  imports = [ hostConfig ];

  mynixos.microvm.guest.enable = true;

  # Avoid guests clock drifting behind when the host suspends
  microvm.kernelParams = [ "clocksource=kvm-clock" ];

  services.chrony = {
    enable = true;
    makestep.enable = false;
    extraConfig = "makestep 1 -1";
  };

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
        readOnly = true;
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
    vsock.cid = vsockCid;
    vcpu = vcpu;
    mem = mem;
    socket = "control.socket";
  };
}
