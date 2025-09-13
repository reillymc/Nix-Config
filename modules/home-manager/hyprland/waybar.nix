{
  ...
}:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 16;
        modules-left = [
          "custom/nix"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "privacy"
          "tray"
          "pulseaudio"
          "bluetooth"
          "network"
          "custom/notification"
        ];
        "custom/nix" = {
          format = "  ";
          tooltip = false;
          on-click = "~/.dotfiles/scripts/wlogout.sh";
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
          icon-size = 16;
        };
        clock = {
          format = "{:%I:%M %p  %a %d/%m}";
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
          on-click = "pavucontrol";
          on-click-right = "~/.dotfiles/scripts/toggleAudioOutput.sh";
          on-click-middle = "~/.dotfiles/scripts/toggleMicrophone.sh";
          format-source = "";
          format-source-muted = "";
          format-icons = {
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
        };
        bluetooth = {
          format = "<span></span>";
          format-off = "<span>󰂲</span>";
          format-disabled = "<span>󰂲</span>";
          format-connected = "<span></span> {num_connections}";
          tooltip-format = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}  {device_address}";
          on-click = "overskride";
          on-click-middle = "~/.dotfiles/scripts/toggleBluetoothPower.sh";
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
          icon-size = 14;
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
          spacing = 10;
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
      }
    ];
    style = ''
      window#waybar {
          background-color: #000;
          border-radius: 0;
          transition: all 0.2s cubic-bezier(0.55, -0.68, 0.48, 1.682);
      }

      .modules-left,
      .modules-center,
      .modules-right {
          padding-left: 12px;
          padding-right: 12px;
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
      #custom-mic {
          color: #fff;
          font-family: "JetBrains Mono", "Symbols Nerd Font Mono";
          font-weight: 800;
          font-size: 12px;
          min-height: 8px;
      }

      #clock {
          margin-left: 8px;
      }

      tooltip {
          background-color: alpha(#000, 0.75);
          border-radius: 16px;
      }

      tooltip label {
          color: #fff;
      }

      #custom-nix {
          font-size: 16px;
          transition: all 0.2s cubic-bezier(0.55, -0.68, 0.48, 1.682);
      }

      #custom-nix:hover {
          color: #bbb;
      }

      #workspaces button {
          box-shadow: none;
          text-shadow: none;
          border: none;
          padding-bottom: 0;
          padding-top: 0;
          color: #bbb;
          font-weight: 600;
          transition: all 0.2s cubic-bezier(0.55, -0.68, 0.48, 1.682);
      }

      #workspaces button.active {
          color: #fff;
          font-weight: 800;
      }

      #workspaces button:hover {
          background: transparent;
          font-weight: 800;
          color: #fff;
      }

      #tray > * {
          opacity: 0.4;
      }
    '';
  };
}
