{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.mynixos.microvm.vms;
  bridge = config.mynixos.microvm.host.bridge;

  nonNull = lib.filterAttrs (_: value: value != null);

  withFallback = fallback: value: if value != null then value else fallback;

  defaultMac =
    name:
    let
      hash = builtins.hashString "sha256" name;
    in
    "02:"
    + lib.concatMapStringsSep ":" (i: lib.substring (2 * i) 2 hash) [
      0
      1
      2
      3
      4
    ];

  mkDropIn =
    serviceConfig:
    lib.mkIf (serviceConfig != { }) {
      overrideStrategy = "asDropin";
      inherit serviceConfig;
    };

  vmServiceConfig =
    limits:
    nonNull {
      CPUWeight = limits.cpuWeight;
      IOWeight = limits.ioWeight;
      Nice = limits.nice;
      MemoryMax = limits.memoryMax;
      TimeoutStopSec = limits.timeoutStopSec;
    };

  virtiofsdServiceConfig =
    limits:
    nonNull {
      CPUWeight = withFallback limits.cpuWeight limits.virtiofsd.cpuWeight;
      IOWeight = withFallback limits.ioWeight limits.virtiofsd.ioWeight;
      Nice = withFallback limits.nice limits.virtiofsd.nice;
    };

  makeVm =
    vm:
    (import ./microvm-base.nix) {
      inherit lib inputs;
      inherit (vm)
        hostConfig
        tapId
        mac
        mem
        vcpu
        vsockCid
        shares
        volumes
        identity
        autostart
        ;
    };
in
{
  imports = [ ./host.nix ];

  options.mynixos.microvm.vms = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            hostConfig = lib.mkOption {
              type = lib.types.path;
              description = "Guest configuration module for this microvm.";
            };

            tapId = lib.mkOption {
              type = lib.types.str;
              default = "microvm-${name}";
              description = "Tap interface name on the host (max 15 characters).";
            };

            mac = lib.mkOption {
              type = lib.types.str;
              default = defaultMac name;
              description = "MAC address of the guest's network interface, derived from the VM name by default.";
            };

            mem = lib.mkOption {
              type = lib.types.ints.positive;
              default = 12288;
              description = "Guest memory in MiB allocated by the hypervisor.";
            };

            vcpu = lib.mkOption {
              type = lib.types.ints.positive;
              default = 8;
              description = "Guest vCPU count allocated by the hypervisor.";
            };

            vsockCid = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = ''
                Guest vsock context id; setting it enables systemd notify
                readiness over vsock and must be unique per microvm.
              '';
            };

            autostart = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Add this microvm to microvms.target.";
            };

            identity = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    file = lib.mkOption {
                      type = lib.types.path;
                      description = "Encrypted age identity to decrypt for the guest.";
                    };

                    secretName = lib.mkOption {
                      type = lib.types.str;
                      default = "${name}/age-identity";
                      description = "Name of the generated age.secrets entry.";
                    };

                    hostDir = lib.mkOption {
                      type = lib.types.str;
                      default = "/var/lib/${name}-keys";
                      description = "Host directory shared with the guest.";
                    };

                    guestMount = lib.mkOption {
                      type = lib.types.str;
                      default = "/run/host-keys";
                      description = "Guest mount point for hostDir.";
                    };

                    tag = lib.mkOption {
                      type = lib.types.str;
                      default = "host-keys";
                      description = "Virtiofs tag for the identity share.";
                    };
                  };
                }
              );
              default = null;
              description = "Host-provided age identity for the guest.";
            };

            shares = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  freeformType = lib.types.attrsOf lib.types.anything;

                  options.proto = lib.mkOption {
                    type = lib.types.str;
                    default = "virtiofs";
                    description = "Share protocol.";
                  };
                }
              );
              default = [ ];
              description = "Extra virtiofs shares for the guest.";
            };

            volumes = lib.mkOption {
              type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
              default = [ ];
              description = "Guest disk images.";
            };

            limits = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  cpuWeight = lib.mkOption {
                    type = lib.types.nullOr lib.types.int;
                    default = 50;
                    description = ''
                      systemd CPUWeight for microvm@${name};
                      microvm-virtiofsd@${name} inherits it unless overridden.
                    '';
                  };

                  ioWeight = lib.mkOption {
                    type = lib.types.nullOr lib.types.int;
                    default = 50;
                    description = ''
                      systemd IOWeight for microvm@${name};
                      microvm-virtiofsd@${name} inherits it unless overridden.
                    '';
                  };

                  nice = lib.mkOption {
                    type = lib.types.nullOr lib.types.int;
                    default = 5;
                    description = ''
                      systemd Nice for microvm@${name};
                      microvm-virtiofsd@${name} inherits it unless overridden.
                    '';
                  };

                  memoryMax = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "systemd MemoryMax for microvm@${name} (e.g. \"18G\").";
                  };

                  timeoutStopSec = lib.mkOption {
                    type = lib.types.nullOr (
                      lib.types.oneOf [
                        lib.types.int
                        lib.types.str
                      ]
                    );
                    default = "60s";
                    description = "systemd TimeoutStopSec for microvm@${name} (seconds or a time span).";
                  };

                  virtiofsd = {
                    cpuWeight = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "systemd CPUWeight for microvm-virtiofsd@${name}.";
                    };

                    ioWeight = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "systemd IOWeight for microvm-virtiofsd@${name}.";
                    };

                    nice = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "systemd Nice for microvm-virtiofsd@${name}.";
                    };
                  };
                };
              };
              default = { };
              description = "systemd resource limits for this microvm's host units (microvm@${name}, microvm-virtiofsd@${name}).";
            };
          };
        }
      )
    );
    default = { };
    description = ''
      Microvms to build on this host. Each entry defines the guest and its
      host-side wiring; identity also generates the agenix secret and share.
    '';
  };

  config = {
    assertions = [
      {
        assertion = lib.all (vm: lib.stringLength vm.tapId <= 15) (lib.attrValues cfg);
        message = "mynixos.microvm.vms: tapId must be 15 characters or fewer.";
      }
      {
        assertion = lib.all (vm: vm.tapId != bridge) (lib.attrValues cfg);
        message = "mynixos.microvm.vms: tapId must differ from the microvm bridge name.";
      }
      {
        assertion =
          let
            tapIds = lib.map (vm: vm.tapId) (lib.attrValues cfg);
          in
          lib.length tapIds == lib.length (lib.unique tapIds);
        message = "mynixos.microvm.vms: tapIds must be unique.";
      }
    ];

    microvm.vms = lib.mapAttrs (_: makeVm) cfg;

    age.secrets = lib.mapAttrs' (
      _: vm:
      lib.nameValuePair vm.identity.secretName {
        file = vm.identity.file;
        path = "${vm.identity.hostDir}/age-identity";
        symlink = false;
      }
    ) (lib.filterAttrs (_: vm: vm.identity != null) cfg);

    systemd = {
      network.networks = lib.mapAttrs' (
        _: vm:
        lib.nameValuePair "21-${vm.tapId}" {
          matchConfig.Name = vm.tapId;
          networkConfig.Bridge = bridge;
        }
      ) cfg;

      services =
        lib.mapAttrs' (
          name: vm: lib.nameValuePair "microvm@${name}" (mkDropIn (vmServiceConfig vm.limits))
        ) cfg
        // lib.mapAttrs' (
          name: vm:
          lib.nameValuePair "microvm-virtiofsd@${name}" (mkDropIn (virtiofsdServiceConfig vm.limits))
        ) cfg;
    };
  };
}
