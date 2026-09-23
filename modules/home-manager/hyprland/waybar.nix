{
  pkgs,
  config,
  lib,
  ...
}:
let
  themeLib = import ../../../lib/theme.nix { inherit lib; };
  theme = config.myhome.display.theme;

  isFlatVariant = monitor: monitor.isUltrawide;

  floatingVariantMonitors = builtins.filter (
    monitor: !(isFlatVariant monitor)
  ) config.myhome.display.monitors;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # setting per monitor
    settings = map (monitor: {
      output = monitor.output;
      layer = "top";
      position = "top";
      spacing = 16;
      margin-left = (if isFlatVariant monitor then 0 else 6);
      margin-right = (if isFlatVariant monitor then 0 else 6);
      margin-top = (if isFlatVariant monitor then 0 else 6);
      modules-left = [
        "custom/nix"
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "privacy"
        "tray"
      ]
      ++ (if monitor.control == "ddcutil" then [ "custom/brightness" ] else [ "backlight" ])
      ++ [
        "pulseaudio"
        "bluetooth"
        "battery"
        "custom/notification"
      ];
      "custom/nix" = {
        format = "  ";
        tooltip = false;
        on-click = "powerMenu";
      };
      "hyprland/workspaces" = {
        format = "{name}";
        tooltip = false;
        format-icons = {
          active = "";
          default = "";
        };
      };
      "hyprland/window" = {
        format = "{title:.120}";
        icon = true;
        icon-size = 10;
      };
      battery = {
        format = "{icon} {capacity}%";
        format-charging = "{icon} 󱐌 {capacity}%";
        format-full = "{icon} 󱐋 {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };
      clock = {
        format = "{:%H:%M, %a %d/%m}  ";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          on-scroll = 1;
          format = {
            months = "<span>{}</span>";
            days = "<span>{}</span>";
            weekdays = "<span>{}</span>";
            today = "<span><b>{}</b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_down";
          on-scroll-down = "shift_up";
        };
      };
      pulseaudio = {
        format = "{format_source} <span>{icon}</span> {volume}%";
        format-muted = "";
        tooltip = false;
        scroll-step = 5;
        max-volume = 100;
        on-click = "pwvucontrol";
        on-click-right = "cycleAudioOutput";
        on-click-middle = "toggleMicrophone";
        format-source = "";
        format-source-muted = "";
        format-icons = {
          # TODO: map from audio devices array additional icon variable
          "bluez_output.94_DB_56_D5_A1_18.1" = "";
          "alsa_output.pci-0000_00_1f.3.iec958-stereo" = "󰓃";
          default = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "reverse-scrolling" = true;
      };
      bluetooth = {
        format = "<span></span>";
        format-off = "<span>󰂲</span>";
        format-disabled = "<span>󰂲</span>";
        format-connected = "<span></span> {num_connections}";
        tooltip-format = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}  {device_address}";
        on-click = "overskride";
      };
      network = {
        format = "{essid}";
        format-wifi = "<span> </span>{essid}";
        format-disconnected = "<span>󰖪 </span>No Network";
        tooltip = false;
        on-click = "nm-connection-editor";
      };
      privacy = {
        icon-spacing = 10;
        icon-size = 10;
        transition-duration = 250;
        modules = [
          {
            type = "screenshare";
            tooltip = true;
            tooltip-icon-size = 20;
          }
          {
            type = "audio-out";
            tooltip = true;
            tooltip-icon-size = 20;
          }
          {
            type = "audio-in";
            tooltip = true;
            tooltip-icon-size = 20;
          }
        ];
      };
      tray = {
        spacing = 12;
        icon-size = 12;
      };
      "backlight" = {
        "device" = "intel_backlight";
        "format" = "{icon} {percent}%";
        "format-icons" = [
          ""
          ""
        ];
        "reverse-scrolling" = true;
      };
      "custom/brightness" = {
        "format" = "{icon} {percentage}%";
        "format-icons" = [
          ""
          ""
        ];
        "return-type" = "json";
        "exec" =
          "${pkgs.ddcutil}/bin/ddcutil --model \"${monitor.model}\" --skip-ddc-checks --sleep-multiplier 0.5 --terse getvcp 10 | ${pkgs.gawk}/bin/gawk '{print \"{\\\"percentage\\\":\" $4 \"}\"}'";
        "on-scroll-up" =
          "${pkgs.ddcutil}/bin/ddcutil --model \"${monitor.model}\" --skip-ddc-checks --sleep-multiplier 0.5 setvcp 10 + 25";
        "on-scroll-down" =
          "${pkgs.ddcutil}/bin/ddcutil --model \"${monitor.model}\" --skip-ddc-checks --sleep-multiplier 0.5 setvcp 10 - 25";
        "on-click-right" =
          let
            ddcCmd = "${pkgs.ddcutil}/bin/ddcutil --model \"${monitor.model}\" --skip-ddc-checks --sleep-multiplier 0.5";
          in
          "current=$(${ddcCmd} --terse getvcp 10 | ${pkgs.gawk}/bin/gawk '{print $4}'); if [ \"$current\" -gt 0 ]; then ${ddcCmd} setvcp 10 0; else ${ddcCmd} setvcp 10 100; fi";
        "interval" = 10;
        "reverse-scrolling" = true;

      };
      "custom/notification" = {
        format = "{icon}";
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
        format-icons = {
          notification = "";
          none = "";
          dnd-notification = "";
          dnd-none = "";
          inhibited-notification = "";
          inhibited-none = "";
          dnd-inhibited-notification = "";
          dnd-inhibited-none = "";
        };
      };
    }) config.myhome.display.monitors;
    style =
      let
        nonUltrawideOverrides = map (monitor: ''
           window#waybar.${monitor.output} {
            border-radius: ${themeLib.asPixels theme.radii.loose};
            padding-top: 12px;
          }

          window#waybar.${monitor.output} .modules-left,
          window#waybar.${monitor.output} .modules-center,
          window#waybar.${monitor.output} .modules-right {
              margin-top: 5px;
              margin-bottom: 1px;
          }
        '') floatingVariantMonitors;

        nonUltrawideVars = map (monitor: ''
          @define-color foreground ${theme.color.foreground0};
          @define-color background ${themeLib.asRGBA theme.color.background0 theme.opacity.overlay};
          @define-color backgroundSoft  ${themeLib.asRGBA theme.color.background0 theme.opacity.elementHeavy};
        '') floatingVariantMonitors;

      in
      ''
        @define-color foreground  ${theme.color.white};
        @define-color background  ${theme.color.black};
        @define-color backgroundSoft  ${themeLib.asRGBA theme.color.black theme.opacity.elementHeavy};
        ${builtins.concatStringsSep "\n" nonUltrawideVars}

        window#waybar {
            background-color: @background;
            border-radius: 0;

            padding: 12px;
            transition: all 0.2s cubic-bezier(0.55, -0.68, 0.48, 1.682);
        }

        .modules-left,
        .modules-center,
        .modules-right {
            padding-left: 12px;
            padding-right: 12px;
            padding-bottom: 4px;
        }

        * {
            margin-top: -1px;
        }

        #custom-nix,
        #workspaces,
        #window,
        #clock,
        #backlight,
        #bluetooth,
        #network,
        #battery,
        #keyboard-state,
        #privacy,
        #tray,
        #pulseaudio,
        #custom-notification,
        #custom-brightness,
        #custom-mic {
            padding-top: 0;
            color: @foreground;
            font-family: "JetBrains Mono", "Symbols Nerd Font Propo";
            font-weight: 800;
            font-size: 12px;
            min-height: 0px;
        }

        #clock {
            margin-left: 8px;
        }

        tooltip {
            background-color: @backgroundSoft;
            border-radius: ${themeLib.asPixels theme.radii.loose};
            border: none;
        }

        tooltip label {
            color: @foreground;
        }

        #custom-nix {
            transition: all 0.2s cubic-bezier(0.55, -0.68, 0.48, 1.682);
        }

        #custom-nix:hover {
            color: #bbb;
        }

        #workspaces button {
            box-shadow: none;
            text-shadow: none;
            border: none;
            margin: 0;
            padding-top: 2px;
            padding-bottom: 0;
            padding-left: 4px;
            padding-right: 4px;
            min-height: 0;
            color: #bbb;
            transition: all 0.2s cubic-bezier(0.55, -0.68, 0.48, 1.682);
        }

        #workspaces label {
            padding: 0;
        }

        #workspaces button.active {
            color: @foreground;
            font-weight: 800;
        }

        #workspaces button:hover {
            background: transparent;
            font-weight: 800;
            color: @foreground;
        }

        #tray {
            opacity: 0.4;
            margin-top: 2px;
            padding-top: 2px;
        }

        #privacy {
            margin-top: 4px;
            color: ${theme.color.warning}
        }

        #window>* {
            margin-top: 1px;

        }

        #window label {
            margin-top: 0px;

        }

        #custom-nix {
            margin-top: 1px;
            font-size: 11px;
        }

        ${builtins.concatStringsSep "\n" nonUltrawideOverrides}
      '';
  };

  home.packages = with pkgs; [
    playerctl
  ];
}
