{ config, lib, ... }:

let
  cfg = config.mynixos.hardware.logitech.device.mx4;
in
{
  options.mynixos.hardware.logitech.device.mx4.enable =
    lib.mkEnableOption "Enable Logitech MX Master 4 mouse support";

  config = lib.mkIf cfg.enable {
    mynixos.hardware.logitech.devices = [
      ''
        {
            name: "MX Master 4";

            // Enable smartshift to automatically switch between ratchet and free-spin.
            smartshift: {
                on: true;
                threshold: 15;
                torque: 60;
            };

            // Enable high-resolution scrolling for a smoother feel.
            hiresscroll: {
                on: true;
            };

            buttons: (
            // ── Top button (behind scroll wheel) ── Toggles SmartShift
            {
                cid: 0xc4;
                action = {
                    type: "Keypress";
                    keys: ["BTN_LEFT", "KEY_LEFTCTRL", "KEY_DOT"];
                }
            },

            // ── Back button (side) ──────────────── Browser Back
            {
                cid: 0x53;
                action: {
                    type: "Keypress";
                    keys: [ "KEY_BACK" ];
                };
            },

            // ── Forward button (side) ───────────── Browser Forward
            {
                cid: 0x56;
                action: {
                    type: "Keypress";
                    keys: [ "KEY_FORWARD" ];
                };
            },

            // ── Thumb rest click ────────────────── Super/Windows key
            {
                cid: 0x1a0;
                action: {
                    type: "Keypress";
                    keys: [ "KEY_LEFTMETA" ];
                };
            },

            // ── Gesture button ──────────────────── Media Gestures
            {
                cid: 0xc3;
                action: {
                    type: "Gestures";
                    gestures: (
                        // Hold + Move Up ──────────────── Volume Up
                        {
                            direction: "Up";
                            mode: "OnRelease";
                            action: {
                                type: "Keypress";
                                keys: [ "KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_UP" ];
                            };
                        },

                        // Hold + Move Down ────────────── Volume Down
                        {
                            direction: "Down";
                            mode: "OnRelease";
                            action: {
                                type: "Keypress";
                                keys: [ "KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_DOWN" ];
                            };
                        },

                        // Hold + Move Left ────────────── Previous Track
                        {
                            direction: "Left";
                            mode: "OnRelease";
                            action: {
                                type: "Keypress";
                                keys: [ "KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_LEFT" ];
                            };
                        },

                        // Hold + Move Right ───────────── Next Track
                        {
                            direction: "Right";
                            mode: "OnRelease";
                            action: {
                                type: "Keypress";
                                keys: [ "KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_RIGHT" ];
                            };
                        },

                        // Simple click (no movement) ──── Play/Pause
                        {
                            direction: "None";
                            mode: "OnRelease";
                            action: {
                                type: "Keypress";
                                keys: [ "KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_L" ];
                            };
                        }
                    );
                };
            }
            );
        }
      ''
    ];
  };
}
