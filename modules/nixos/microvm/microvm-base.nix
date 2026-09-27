{
  lib,
  inputs,
  hostConfig,
  tapId,
  mac,
  mem,
  vcpu,
  vsockCid,
  shares,
  volumes,
  identity,
  autostart,
}:
let
  guestDefaults = {
    imports = [ hostConfig ];

    age.identityPaths = lib.optional (identity != null) "${identity.guestMount}/age-identity";

    # Avoid guests clock drifting behind when the host suspends
    microvm.kernelParams = [ "clocksource=kvm-clock" ];

    services.chrony = {
      enable = true;
      makestep.enable = false;
      extraConfig = "makestep 1 -1";
    };

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
          inherit mac;
        }
      ];

      hypervisor = "cloud-hypervisor";
      vsock.cid = vsockCid;
      inherit mem vcpu;
    };
  };

  identityShare = {
    proto = "virtiofs";
    inherit (identity) tag;
    source = identity.hostDir;
    mountPoint = identity.guestMount;
    readOnly = true;
  };
in
{
  inherit autostart;
  specialArgs = { inherit inputs; };
  config = {
    imports = [
      inputs.microvm.nixosModules.microvm
      inputs.agenix.nixosModules.default
      inputs.impermanence.nixosModules.impermanence
      guestDefaults
    ];

    microvm.shares = shares ++ lib.optional (identity != null) identityShare;
    microvm.volumes = volumes;
  }
  // lib.optionalAttrs (identity != null) {
    fileSystems.${identity.guestMount}.neededForBoot = true;
  };
}
