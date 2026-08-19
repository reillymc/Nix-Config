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
            path = "/home/dev/.config/opencode/api-key";
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

      users.mutableUsers = false;

      # agenix activation (runs as root) mkdir -p's these under ~/.config; the
      # dirs end up root-owned and block home-manager's user-level activation.
      # tmpfiles runs before home-manager-dev.service and (re)asserts ownership.
      systemd.tmpfiles.rules = [
        "d /home/dev 0700 1000 1000 -"
        "d /home/dev/.config 0755 1000 1000 -"
        "d /home/dev/.config/opencode 0755 1000 1000 -"
      ];

      users.users.dev.extraGroups = [
        "docker"
      ];
      users.users.dev.shell = pkgs.zsh;

      home-manager.users.dev = {
        imports = [ ./microvm-home.nix ];
      };

      virtualisation.docker.enable = true;

      # Dev ports forwarded from the host/tailnet (see host.nix devPorts).
      networking.firewall.allowedTCPPorts = [
        3000
        3001
        8081
      ];

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
      zramSwap.enable = true;
      zramSwap.memoryPercent = 50; # Adjust based on how much RAM to allocate for compressed swap
      boot.kernel.sysctl."vm.swappiness" = 10;
    };
  };
}
