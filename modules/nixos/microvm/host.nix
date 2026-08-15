{
  lib,
  ...
}:

let
  devvmIp = "192.168.83.6";
  devPorts = [ 3000 3001 8081 ];
  fwd = port: {
    sourcePort = port;
    destination = "${devvmIp}:${toString port}";
    proto = "tcp";
  };
in
{
  systemd.network.enable = true;
  networking.useNetworkd = true; # todo move to machien cofnig?

  systemd.network.netdevs."20-microbr".netdevConfig = {
    Kind = "bridge";
    Name = "microbr";
  };

  systemd.network.networks."20-microbr" = {
    matchConfig.Name = "microbr";
    addresses = [ { Address = "192.168.83.1/24"; } ];
    networkConfig = {
      ConfigureWithoutCarrier = true;
    };
  };

  systemd.network.networks."21-microvm-tap" = {
    matchConfig.Name = "microvm*";
    networkConfig.Bridge = "microbr";
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "microbr" ];
    externalInterface = "enp14s0f3u1u2u1";
    forwardPorts = map fwd devPorts;

    # Forward the same dev ports when they arrive on terra's tailscale interface,
    # so the devvm is reachable over the tailnet.
    extraCommands = lib.concatMapStringsSep "\n" (port: ''
      iptables -w -t nat -A nixos-nat-pre -i tailscale0 -p tcp --dport ${toString port} -j DNAT --to-destination ${devvmIp}:${toString port}
      iptables -w -t filter -A nixos-filter-forward -i tailscale0 -p tcp --dport ${toString port} -j ACCEPT
    '') devPorts;
  };
}
