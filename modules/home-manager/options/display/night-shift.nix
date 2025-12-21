{ lib, ... }:

{
  options = {
    myhome = {
      display = {
        nightShift = lib.mkOption {
          type = lib.types.submodule {
            options = {
              maxTime = lib.mkOption {
                type = lib.types.str;
                description = "Time of day when 'day' (normal color temperature) starts (HH:MM).";
              };

              minTime = lib.mkOption {
                type = lib.types.str;
                description = "Time of day when 'night' (night shift temperature) window starts (HH:MM).";
              };
            };
          };
          default = { };
          description = "Configuration for automatically adjusting monitor temperature on schedule.";
        };
      };
    };
  };

}
