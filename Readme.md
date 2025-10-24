# NixOS System Configuration

My NixOS system configurations

## Rebuilding

`sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#terra`

or alternatively, rebuild directly into light mode
`sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#terra --specialisation light`

## Switch themes

`sudo systemctl start switchToLightMode.service`

`sudo systemctl start switchToDarkMode.service`

# Options

## Home (`myhome`)

These options are configured in a host's `home.nix` configuration. They are not shared with the host NixOS system configuration options (`mynixos`). When control is required across both domains, the configuration will be found in the NixOS system configuration and is passed into the home module.

### audio

#### devices

A list of audio outputs that should be actively used by the system, e.g. in audio output cycle script.
The device is listed by the PipeWire node name. This value can be found using `wpctl`:

1. Run `wpctl status` and find desired device. Note the numeric id.
2. Run `wpctl inspect <numberic id>` and copy the value from the `node.name` property

e.g.

```nix
[
    "bluez_output.00_00_00_00_00_0.1"
    "alsa_output.pci-0000_00_00.1.hdmi-stereo"
]
```

### monitors

A list of display outputs that should be actively used by the system, e.g. in hyprland's configuration. Each item should provide all the required keys, e.g.

```nix
{
    output = "DP-1";
    model = "eiq-495KCSUW";
    resolution = "5120x1440";
    refreshRate = 144;
    position = "0x0";
    scale = 1.0;
    bitdepth = 10;
}
```
