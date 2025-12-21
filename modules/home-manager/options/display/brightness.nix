{ lib, ... }:

{
  options = {
    myhome = {
      display = {
        brightness = lib.mkOption {
          type = lib.types.submodule {
            options = {
              maxTime = lib.mkOption {
                type = lib.types.str;
                description = "Time of day when 'day' (max brightness) window starts (HH:MM).";
              };

              minTime = lib.mkOption {
                type = lib.types.str;
                description = "Time of day when 'night' (min brightness) window starts (HH:MM).";
              };
            };
          };
          default = { };
          description = "Configuration for automatically adjusting monitor brightness on schedule.";
        };
      };
    };
  };

}
