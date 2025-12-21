{ lib, ... }:

{
  options = {
    myhome = {
      display = {
        theme = lib.mkOption {
          type = lib.types.submodule {
            options = {
              lightTime = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Time of day to switch to light theme (HH:MM).";
              };

              darkTime = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Time of day to switch to dark theme (HH:MM).";
              };
            };
          };
          default = { };
          description = "Configuration for automatically switching system theme.";
        };
      };
    };
  };
}
