{ config, ... }:

{
  services.gammastep = {
    enable = true;
    tray = true;
    temperature = {
      day = 6500;
      night = 3200;
    };
    dawnTime = config.myhome.display.nightShift.minTime;
    duskTime = config.myhome.display.nightShift.maxTime;
  };
}
