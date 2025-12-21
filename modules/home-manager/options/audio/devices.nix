{ lib, ... }:

{
  options = {
    myhome = {
      audio = {
        devices = lib.mkOption {
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
      };
    };
  };

}
