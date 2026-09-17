{ lib, ... }:

{
  options = {
    myhome = {
      display = {
        monitors = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                output = lib.mkOption {
                  type = lib.types.str;
                  description = "Output name, e.g. DP-1";
                };

                model = lib.mkOption {
                  type = lib.types.str;
                  description = "Monitor model name, e.g. eiq-495KCSUW";
                };

                resolution = lib.mkOption {
                  type = lib.types.str;
                  default = "5120x1440";
                  description = "Resolution, e.g. 5120x1440";
                };

                refreshRate = lib.mkOption {
                  type = lib.types.int;
                  default = 144;
                  description = "Refresh rate in Hz";
                };

                position = lib.mkOption {
                  type = lib.types.str;
                  default = "0x0";
                  description = "Monitor position, e.g. 0x0";
                };

                scale = lib.mkOption {
                  type = lib.types.float;
                  default = 1.0;
                  description = "Scale factor, e.g. 1.0";
                };

                bitdepth = lib.mkOption {
                  type = lib.types.nullOr lib.types.int;
                  default = null;
                  description = "Optional bitdepth, e.g. 10. If null, omitted.";
                };

                isUltrawide = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Whether the monitor is ultrawide or not.";
                };

                control = lib.mkOption {
                  type = lib.types.nullOr (
                    lib.types.enum [
                      "ddcutil"
                      "brightnessctl"
                    ]
                  );
                  default = null;
                  description = ''
                    Optional brightness control method for this monitor.
                    Use "brightnessctl" for internal laptop panels and "ddcutil" for external DDC/CI monitors.
                    If null, internal panels are auto-detected and will use brightnessctl.
                  '';
                };
              };
            }
          );
          default = [ ];
          description = "A list of display outputs that should be actively used by the system, e.g. in hyprland's configuration. Each item should provide all the required keys, e.g.";
          example = ''
            [
              {
                output = "DP-1";
                model = "eiq-495KCSUW";
                resolution = "5120x1440";
                refreshRate = 144;
                position = "0x0";
                scale = 1.0;
                bitdepth = 10;
              }
            ]
          '';
        };
      };
    };
  };

}
