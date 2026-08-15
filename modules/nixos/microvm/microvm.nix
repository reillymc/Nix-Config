{
  inputs,
  pkgs,
  ...
}:

let
  inherit (inputs)
    nixpkgs
    microvm
    home-manager
    agenix
    impermanence
    ;

  microvmBase = import ./microvm-base.nix;
in
{
  age.secrets."devvm/age-identity" = {
    file = ../../../secrets/devvm/age-identity.age;
    path = "/var/lib/devvm-keys/age-identity"; # NOT under /run/agenix, so we don't share all host secrets
    symlink = false; # share must expose a real file, not a guest-broken symlink -- todo is this true?
  };

  microvm.vms.devvm = {
    autostart = true;
    config = {
      imports = [
        microvm.nixosModules.microvm
        agenix.nixosModules.default
        impermanence.nixosModules.impermanence
        (microvmBase {
          hostName = "devvm";
          ipAddress = "192.168.83.6";
          tapId = "microvm4";
          mac = "02:00:00:00:00:05";
          inherit
            nixpkgs
            home-manager
            ;
        })
      ];

      age = {
        identityPaths = [ "/run/host-keys/age-identity" ];
        secrets = {
          "opencode-go/api-key" = {
            file = ../../../secrets/devvm/opencode-go-api-key.age;
            owner = "dev";
            group = "dev";
            mode = "0400";
          };
        };
      };

      microvm.shares = [
        {
          proto = "virtiofs";
          tag = "workspace";
          source = "/home/reilly/Projects";
          mountPoint = "/projects";
          # cache = "metadata";
        }
        {
          proto = "virtiofs";
          tag = "host-keys";
          source = "/var/lib/devvm-keys";
          mountPoint = "/run/host-keys";
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

      users.mutableUsers = false;

      users.users.dev.extraGroups = [
        "docker"
      ];
      users.users.dev.shell = pkgs.zsh;

      home-manager.users.dev = {
        imports = [ ./microvm-home.nix ];
      };

      virtualisation.docker.enable = true;

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

      # 8G swapfile on /var (var.img) as an OOM safety net for build spikes.
      # Created automatically by NixOS when `size` is set; disk-backed so it
      # doesn't consume RAM. swappiness 10 keeps swap as pure overflow.
      swapDevices = [
        {
          device = "/var/swapfile";
          size = 8192; # MiB
        }
      ];
      boot.kernel.sysctl."vm.swappiness" = 10;

    };
  };
}
