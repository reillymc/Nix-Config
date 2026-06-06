{
  lib,
  theme,
  ...
}:

let
  paletteType = lib.types.submodule {
    options = {
      foreground = lib.mkOption {
        type = lib.types.str;
        default = "#ffffff";
      };

      background = lib.mkOption {
        type = lib.types.str;
        default = "#000000";
      };

      accent = lib.mkOption {
        type = lib.types.str;
        default = "#2494da";
      };

      white = lib.mkOption {
        type = lib.types.str;
        default = "#ffffff";
      };
    };
  };
in
{
  options.myhome.display.design = lib.mkOption {
    type = lib.types.attrs;
    default = import ../../theme { mode = theme; };
  };

  options.myhome.display.palette.light = lib.mkOption {
    type = paletteType;
    default = {
      foreground = "#000000";
      background = "#ffffff";
      accent = "#0066cc";
      white = "#ffffff";
    };
    description = "Theme light color palette.";
  };
  options.myhome.display.palette.dark = lib.mkOption {
    type = paletteType;
    default = {
      foreground = "#ffffff";
      background = "#000000";
      accent = "#2494da";
      white = "#ffffff";
    };
    description = "Theme dark color palette.";
  };
  options.myhome.display.palette.color = lib.mkOption {
    type = paletteType;
    readOnly = true;
    description = "Theme color palette.";
  };
  options.myhome.display.palette.border = lib.mkOption {
    type = lib.types.submodule {
      options = {
        tight = lib.mkOption {
          type = lib.types.str;
          default = "12";
          description = "Border radius for tight elements.";
        };
        regular = lib.mkOption {
          type = lib.types.str;
          default = "16";
          description = "Border radius for regular elements.";
        };
      };
    };
    default = { };
    description = "Border radius settings for UI elements.";
  };
  options.myhome.display.palette.opacity = lib.mkOption {
    type = lib.types.submodule {
      options = {
        extra-light = lib.mkOption {
          type = lib.types.float;
          default = 0.2;
          description = "Opacity for very low-opacity elements.";
        };
        light = lib.mkOption {
          type = lib.types.float;
          default = 0.5;
          description = "Opacity for low-opacity elements.";
        };
        regular = lib.mkOption {
          type = lib.types.float;
          default = 0.8;
          description = "Opacity for medium-opacity elements.";
        };
        heavy = lib.mkOption {
          type = lib.types.float;
          default = 1.0;
          description = "Opacity for high-opacity elements.";
        };
      };
    };
    default = { };
    description = "Opacity settings for UI elements.";
  };
  options.myhome.display.palette.size.height = lib.mkOption {
    type = lib.types.submodule {
      options = {
        regular = lib.mkOption {
          type = lib.types.float;
          default = 0.5;
          description = "Height for regular popup windows.";
        };
        large = lib.mkOption {
          type = lib.types.float;
          default = 0.75;
          description = "Height for large popup windows.";
        };
      };
    };
    default = { };
    description = "Height settings for popup windows.";
  };
  options.myhome.display.palette.size.width = lib.mkOption {
    type = lib.types.submodule {
      options = {
        regular = lib.mkOption {
          type = lib.types.int;
          default = 720;
          description = "Width for regular popup windows.";
        };
        large = lib.mkOption {
          type = lib.types.enum [ "monitor_h" ];
          default = "monitor_h";
          description = "Width for large popup windows.";
        };
      };
    };
    default = { };
    description = "Width settings for popup windows.";
  };
  options.myhome.display.palette.layout = lib.mkOption {
    type = lib.types.submodule {
      options = {
        reservedYSpace = lib.mkOption {
          type = lib.types.int;
          default = 18;
          description = "Height reserved for system bars and docks.";
        };
        reservedXSpace = lib.mkOption {
          type = lib.types.int;
          default = 0;
          description = "Width reserved for sidebars.";
        };
      };
    };
    default = { };
    description = "Color palette and size settings for the system theme.";
  };

}
