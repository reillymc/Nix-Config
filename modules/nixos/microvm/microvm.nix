{
  inputs,
  ...
}:

let
  inherit (inputs)
    microvm
    agenix
    impermanence
    ;

  microvmBase = import ./microvm-base.nix;
in
{
  age.secrets."mist/age-identity" = {
    file = ../../../secrets/mist/age-identity.age;
    path = "/var/lib/mist-keys/age-identity"; # NOT under /run/agenix, so we don't share all host secrets
    symlink = false; # share must expose a real file, not a guest-broken symlink -- todo is this true?
  };

  microvm.vms.mist = {
    autostart = true;
    specialArgs = { inherit inputs; };
    config = {
      imports = [
        microvm.nixosModules.microvm
        agenix.nixosModules.default
        impermanence.nixosModules.impermanence
        (microvmBase {
          hostConfig = ../../../hosts/mist/configuration.nix;
          tapId = "microvm4";
          mac = "02:00:00:00:00:05";
        })
      ];

      microvm.shares = [
        {
          proto = "virtiofs";
          tag = "workspace";
          source = "/home/reilly/Projects";
          mountPoint = "/home/dev/Projects";
        }
        {
          proto = "virtiofs";
          tag = "host-keys";
          source = "/var/lib/mist-keys";
          mountPoint = "/run/host-keys";
          readOnly = true;
        }
      ];

      fileSystems."/run/host-keys".neededForBoot = true;

      microvm.volumes = [
        {
          mountPoint = "/var";
          image = "var.img";
          size = 73728; # 72 GiB
        }
      ];
    };
  };
}
