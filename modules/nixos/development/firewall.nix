{
  config,
  lib,
  ...
}:
{
  options = {
    mynixos.firewall.commonPorts.enable = lib.mkEnableOption "open common ports for development servers";
  };

  config = lib.mkIf config.mynixos.firewall.commonPorts.enable {
    # Open ports in the firewall.
    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 8000;
          to = 8001;
        }
        {
          from = 5000;
          to = 5003;
        }
        {
          from = 8080;
          to = 8084;
        }
        {
          from = 3000;
          to = 3002;
        }
      ];
      checkReversePath = false;
    };
  };
}
