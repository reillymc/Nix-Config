{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.mynixos.hardware.logitech;
in
{
  imports = [
    ./devices
  ];

  options.mynixos.hardware.logitech.enable = lib.mkEnableOption "Logitech device support";
  options.mynixos.hardware.logitech.devices = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of Logitech device configurations as strings (logid.cfg entries)";
  };

  config = lib.mkIf config.mynixos.hardware.logitech.enable {
    hardware.logitech.wireless.enable = true;

    environment.etc."logid.cfg".text = ''
      devices: (
      ${lib.concatStringsSep "\n" cfg.devices}
      );
    '';

    systemd.services.logiops = {
      description = "Userspace driver for Logitech HID++ devices";
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [
        pkgs.logiops
        config.environment.etc."logid.cfg".text
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
    };

    environment.systemPackages = with pkgs; [
      logiops
    ];
  };
}
