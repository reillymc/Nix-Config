{
  config,
  lib,
  ...
}:

let
  devices = config.myhome.audio.devices;

  mkRule =
    idx: name:
    let
      priority = 10000 - idx;
      monitor = if lib.hasPrefix "bluez_" name then "bluez" else "alsa";
    in
    ''
      monitor.${monitor}.rules = [
        {
          matches = [
            { node.name = "${name}" }
          ]
          actions = {
            update-props = {
              priority.session = ${toString priority}
              priority.driver = ${toString priority}
            }
          }
        }
      ]
    '';
in
{
  xdg.configFile."wireplumber/wireplumber.conf.d/90-audio-priority.conf".text =
    lib.concatStringsSep "\n" (lib.imap0 mkRule devices);
}
