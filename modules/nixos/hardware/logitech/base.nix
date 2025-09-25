{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.mynixos.hardware.logitech.enable = lib.mkEnableOption "Enable Logitech M720 configuration";

  config = lib.mkIf config.mynixos.hardware.logitech.enable {
    hardware.logitech.wireless.enable = true;

    systemd.services.logiops = {
      description = "An unofficial userspace driver for HID++ Logitech devices";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [
        pkgs.logiops
        config.environment.etc."logid.cfg".text
      ];
    };

    environment.systemPackages = with pkgs; [
      logiops
    ];
  };
}
