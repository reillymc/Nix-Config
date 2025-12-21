{ config, lib, ... }:

{
  services.gammastep =
    lib.mkIf
      (
        config.myhome.display.nightShift.clearTime != null
        && config.myhome.display.nightShift.shiftTime != null
      )
      {
        enable = true;
        tray = true;
        temperature = {
          day = 6500;
          night = 3200;
        };
        dawnTime = config.myhome.display.nightShift.clearTime;
        duskTime = config.myhome.display.nightShift.shiftTime;
      };
}
