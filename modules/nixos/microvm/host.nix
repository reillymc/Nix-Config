{
  config,
  lib,
  ...
}:
let
  cfg = config.mynixos.microvm.host;
in
{
  options.mynixos.microvm.host = {
    externalInterface = lib.mkOption {
      type = lib.types.str;
      description = ''
        WAN-facing interface that microvm guest traffic is NATed through.
      '';
    };

    bridge = lib.mkOption {
      type = lib.types.str;
      default = "microbr";
      description = "Bridge that microvm tap interfaces are attached to.";
    };

    bridgeAddress = lib.mkOption {
      type = lib.types.str;
      default = "192.168.83.1/24";
      description = "Address assigned to the microvm bridge.";
    };

    autostart = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Start microvms from a boot-time timer instead of blocking boot on
          microvms.target.
        '';
      };

      onBootSec = lib.mkOption {
        type = lib.types.str;
        default = "0";
        description = "Delay after boot before microvms.target is started.";
      };

      accuracySec = lib.mkOption {
        type = lib.types.str;
        default = "1s";
        description = "Timer accuracy for the microvm autostart timer.";
      };
    };
  };

  config = {
    networking.useNetworkd = true;

    networking.nat = {
      enable = true;
      internalInterfaces = [ cfg.bridge ];
      inherit (cfg) externalInterface;
    };

    systemd = {
      network = {
        netdevs."20-${cfg.bridge}".netdevConfig = {
          Kind = "bridge";
          Name = cfg.bridge;
        };

        networks."20-${cfg.bridge}" = {
          matchConfig.Name = cfg.bridge;
          addresses = [ { Address = cfg.bridgeAddress; } ];
          networkConfig = {
            ConfigureWithoutCarrier = true;
          };
        };
      };

      targets.microvms = lib.mkIf cfg.autostart.enable {
        wantedBy = lib.mkForce [ ];
        wants = [ "systemd-networkd.service" ];
        after = [ "systemd-networkd.service" ];
      };

      timers.microvm-autostart = lib.mkIf cfg.autostart.enable {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = cfg.autostart.onBootSec;
          AccuracySec = cfg.autostart.accuracySec;
          Unit = "microvms.target";
        };
      };
    };
  };
}
