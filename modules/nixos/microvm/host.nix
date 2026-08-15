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
    forwardPorts = [
      { sourcePort = 3000; destination = "192.168.83.6:3000"; proto = "tcp"; }
      { sourcePort = 3001; destination = "192.168.83.6:3001"; proto = "tcp"; }
      { sourcePort = 3002; destination = "192.168.83.6:3002"; proto = "tcp"; }
      { sourcePort = 8000; destination = "192.168.83.6:8000"; proto = "tcp"; }
      { sourcePort = 8001; destination = "192.168.83.6:8001"; proto = "tcp"; }
      { sourcePort = 8002; destination = "192.168.83.6:8002"; proto = "tcp"; }
    ];
  };

}
