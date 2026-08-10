{ config, lib, ... }:

let
  addHours =
    time: hours:
    let
      parts = lib.splitString ":" time;
      h = lib.strings.toInt (lib.strings.removePrefix "0" (builtins.elemAt parts 0));
      m = builtins.elemAt parts 1;
      newH = toString (lib.mod (h + hours) 24);
      paddedH = if builtins.stringLength newH == 1 then "0" + newH else newH;
    in
    "${paddedH}:${m}";
in
{
  services.gammastep =
    lib.mkIf
      (
        config.myhome.display.nightShift.clearTime != null
        && config.myhome.display.nightShift.shiftTime != null
      )
      {
        enable = true;
        tray = false;
        temperature = {
          day = 6500;
          night = 3200;
        };
        dawnTime = "${config.myhome.display.nightShift.clearTime}-${addHours config.myhome.display.nightShift.clearTime 1}";
        duskTime = "${config.myhome.display.nightShift.shiftTime}-${addHours config.myhome.display.nightShift.shiftTime 1}";
      };
}
