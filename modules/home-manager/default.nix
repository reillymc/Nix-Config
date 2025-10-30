{
  config,
  lib,
  ...
}:

{
  imports = [
    ./development
    ./hyprland
    ./utilities
    ./web-apps
    ./theme.nix
    ./scripts.nix
  ];

  options = {
    myhome = {
      myUnfreePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of predicates to allow unfree packages.
          These will be merged, letting allowUnfreePredicate be defined in a modular way.
        '';
      };

      audio.devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = ''
          A list of audio outputs that should be actively used by the system, e.g. in audio output cycle script.
          The device is listed by the PipeWire node name. This value can be found using `wpctl`:

          1. Run `wpctl status` and find desired device. Note the numeric id.
          2. Run `wpctl inspect <numberic id>` and copy the value from the `node.name` property
        '';
        default = [ ];
        example = [
          "bluez_output.00_00_00_00_00_0.1"
          "alsa_output.pci-0000_00_00.1.hdmi-stereo"
        ];
      };

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

  config = {

    nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) config.myhome.myUnfreePackages;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
