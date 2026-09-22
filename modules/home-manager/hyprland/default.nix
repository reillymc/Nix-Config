{
  pkgs,
  config,
  mynixos,
  lib,
  ...
}:
let
  themeLib = import ../../../lib/theme.nix { inherit lib; };
  theme = config.myhome.display.theme;

  cursorName = if theme.mode == "light" then "Bibata-Modern-Classic" else "Bibata-Modern-Ice";
  cursorSize = 24;

  monitors = map (
    mon:
    {
      inherit (mon) output position;
      mode = "${mon.resolution}@${toString mon.refreshRate}";
      scale = toString mon.scale;
    }
    // lib.optionalAttrs (mon.bitdepth != null) {
      inherit (mon) bitdepth;
    }
  ) config.myhome.display.monitors;

  wallpaperPath =
    if theme.mode == "light" then "~/.local/share/wallpaper" else "~/.local/share/wallpaper-dark";

  wallpapers = map (mon: {
    monitor = mon.output;
    path = wallpaperPath;
    fit_mode = "cover";
  }) config.myhome.display.monitors;

  lockdown = pkgs.writeShellScriptBin "lockdown" ''
    if (($1 > 3)); then
      hyprctl dispatch 'hl.dsp.exit()'
    fi
  '';

  startup = pkgs.writeShellScriptBin "startup" ''
    # Get the current hour in 24-hour format (e.g. 06, 14, etc.)
    current_hour=$(date +%H)

    # Convert to an integer (to avoid issues with leading zeros)
    current_hour=$((10#$current_hour))

    # Waybar fails to start if started too early, so delay and restart service
    sleep 3
    systemctl --user restart waybar # Workaround for waybar systemd service failing to start at launch
  '';

  search = pkgs.writeShellScriptBin "search" ''
    # Requires wl-clipboard, TODO: ensure dependency is handled independently of clipse
    firefox --new-tab https://www.google.com/search?q="$(wl-paste --primary)"
  '';

  clipboardManager = pkgs.writeShellScriptBin "clipboardManager" ''
    exec ghostty --class=com.my.clipboard --confirm-close-surface=false --background=${theme.color.background0} --background-blur=false -e clipse
  '';

  ghosttyMist = pkgs.writeShellScriptBin "ghostty-mist" ''
    exec uwsm app -- ghostty --theme='Adwaita Dark' -e ssh mist
  '';

  heightRegular = "(monitor_h*${toString theme.size.popup.regular.height})";
  heightLarge = "(monitor_h*${toString theme.size.popup.large.height})";

  widthRegular = "(monitor_h*${toString theme.size.popup.regular.width})";
  widthLarge = "(monitor_h*${toString theme.size.popup.large.width})";

  popupHeightPercent = themeLib.toPercentInt theme.size.popup.regular.height;
  popupWidthPercent = themeLib.toPercentInt theme.size.popup.regular.width;
  popupTitles = lib.generators.toLua { multiline = false; } config.myhome.display.popupify.titles;

  mkLuaInline = lib.generators.mkLuaInline;
in
{
  imports = [
    ./waybar.nix
    ./clipse.nix
    ./rofi.nix
    ./swaync.nix
    ./audio.nix
  ];

  config = lib.mkIf mynixos.hyprland.enable {
    myhome.state.directories = [
      {
        directory = ".local/share/keyrings";
        backup.enable = false;
      }
      {
        directory = ".config/kdeconnect";
        backup.enable = false;
      }
    ];

    myhome.state.files = [
      {
        file = ".local/share/wallpaper";
        backup.enable = false;
      }
      {
        file = ".local/share/wallpaper-dark";
        backup.enable = false;
      }
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
      package = null;
      portalPackage = null;
      configType = "lua";
      systemd.enable = false;
      settings = {
        config = {
          general = {
            gaps_in = 3;
            gaps_out = 6;
            border_size = 0;

            layout = "master";
          };

          input = {
            follow_mouse = 1;
            kb_layout = "us";

            touchpad = {
              natural_scroll = true;
              clickfinger_behavior = true;
              disable_while_typing = false;
            };
          };

          misc = {
            force_default_wallpaper = 0;
            disable_splash_rendering = true;
            disable_hyprland_logo = true;
          };

          binds = {
            movefocus_cycles_fullscreen = 0;
          };

          cursor = {
            inactive_timeout = 5;
            no_hardware_cursors = true; # temporary workaround for cursor not changing to proper glyph after unstable switch
          };

          animations = {
            enabled = true;
          };

          decoration = {
            rounding = theme.radii.loose;
            active_opacity = theme.opacity.active;
            inactive_opacity = theme.opacity.inactive;

            blur = {
              size = 10;
              passes = 3;
              noise = 0.03;
              brightness = 0.9;
            };

            shadow = {
              enabled = true;
              range = 16;
              color = "0x1a1a1a1a";
            };
          };

          dwindle = {
            preserve_split = true; # you probably want this
          };

          master = {
            # new_status = master
            orientation = "center";
            mfact = 0.5;
            always_keep_position = true;
            slave_count_for_center_master = 0;
            allow_small_split = true;
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          group = {
            groupbar = {
              font_weight_active = "bold";
              indicator_height = 0;
              gradient_rounding = 8;
              col = {
                active = "0xff000000";
                inactive = "0xaa000000";
              };
              gradients = true;
              gaps_in = 0;
              gaps_out = 4;
              keep_upper_gap = false;
            };
          };
        };

        monitor = monitors;

        env = [
          {
            _args = [
              "XCURSOR_SIZE"
              "24"
            ];
          }
          {
            _args = [
              "GTK_DECORATION_LAYOUT"
              ":"
            ];
          }
        ];

        curve = [
          {
            _args = [
              "easeOutQuint"
              {
                type = "bezier";
                points = [
                  [
                    0.23
                    1
                  ]
                  [
                    0.32
                    1
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "bouncy"
              {
                type = "spring";
                mass = 1;
                stiffness = 25;
                dampening = 9;
              }
            ];
          }
          {
            _args = [
              "snappy"
              {
                type = "spring";
                mass = 1;
                stiffness = 80;
                dampening = 16;
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "global";
            enabled = true;
            speed = 8.32;
            bezier = "easeOutQuint";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 4.5;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windows";
            enabled = true;
            speed = 1.6;
            spring = "snappy";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 1.37;
            spring = "snappy";
            style = "popin 87%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 0.5;
            spring = "snappy";
            style = "popin 87%";
          }
          {
            leaf = "fadeIn";
            enabled = true;
            speed = 1.46;
            bezier = "easeOutQuint";
          }
          {
            leaf = "fadeOut";
            enabled = true;
            speed = 1.22;
            bezier = "easeOutQuint";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 2.52;
            bezier = "easeOutQuint";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 3.18;
            bezier = "easeOutQuint";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 3.32;
            bezier = "easeOutQuint";
            style = "fade";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 2.0;
            bezier = "easeOutQuint";
            style = "fade";
          }
          {
            leaf = "fadeLayersIn";
            enabled = true;
            speed = 3.0;
            bezier = "easeOutQuint";
          }
          {
            leaf = "fadeLayersOut";
            enabled = true;
            speed = 2.0;
            bezier = "easeOutQuint";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 1.2;
            spring = "bouncy";
            style = "slide";
          }
          {
            leaf = "workspacesIn";
            enabled = true;
            speed = 1.0;
            spring = "bouncy";
            style = "slide";
          }
          {
            leaf = "workspacesOut";
            enabled = true;
            speed = 1.2;
            spring = "bouncy";
            style = "slide";
          }
          {
            leaf = "specialWorkspaceIn";
            enabled = true;
            speed = 1.5;
            spring = "bouncy";
            style = "slidefadevert";
          }
          {
            leaf = "specialWorkspaceOut";
            enabled = true;
            speed = 1.5;
            spring = "bouncy";
            style = "slidefadevert";
          }
          {
            leaf = "zoomFactor";
            enabled = true;
            speed = 5.82;
            bezier = "easeOutQuint";
          }
        ];

        gesture = [
          {
            fingers = 3;
            direction = "pinch";
            action = "fullscreen";
            mode = "maximized";
          }
          {
            fingers = 3;
            direction = "swipe";
            action = "resize";
            scale = 1.25;
          }
          {
            fingers = 4;
            direction = "pinchin";
            action = mkLuaInline ''function() hl.exec_cmd("launcher") end'';
          }
          {
            fingers = 4;
            direction = "pinchout";
            action = mkLuaInline ''function() hl.exec_cmd("pkill -x rofi || hyprctl dispatch 'hl.dsp.window.close()'") end'';
          }
          {
            fingers = 4;
            direction = "horizontal";
            action = "workspace";
          }
          {
            fingers = 4;
            direction = "vertical";
            action = "special";
            workspace_name = "magic";
          }
        ];

        workspace_rule = [
          {
            workspace = "f[1]";
            no_rounding = true;
            border_size = 0;
            gaps_out = 0;
          }
          {
            workspace = "w[tv2]";
            layout_opts = {
              orientation = "left";
            };
          }
          {
            workspace = "m[eDP-1]";
            layout = "dwindle";
          }
        ]
        # TODO: for laptop, work out if requred and make configurable if so
        # workspace = m[eDP-1]w[tv1], layoutopt:orientation:left
        ++ map (mon: {
          workspace = "w[t1]f[-1]m[${mon.output}]";
          gaps_out = 6;
          gaps_in = 0;
        }) config.myhome.display.monitors
        ++ [
          {
            workspace = "w[t1]m[n]";
            gaps_out = {
              top = 6;
              right = 1024;
              bottom = 6;
              left = 1024;
            };
            gaps_in = 0;
          }
          {
            workspace = "w[tg1]";
            gaps_out = 6;
            gaps_in = 0;
          }
        ];

        window_rule = [
          {
            name = "clipboard";
            match = {
              class = "com.my.clipboard";
            };
            float = true;
            size = [
              widthRegular
              heightRegular
            ];
            stay_focused = true;
            animation = "popin";
            dim_around = true;
          }
          {
            name = "stay-focused-modal";
            match = {
              modal = true;
            };
            stay_focused = true;
          }
          {
            name = "pip-opacity";
            match = {
              initial_title = "Picture-in-Picture";
            };
            opacity = toString theme.opacity.active;
          }
          {
            name = "nautilus-previewer";
            match = {
              class = "org.gnome.NautilusPreviewer";
            };
            float = true;
            size = [
              widthLarge
              heightLarge
            ];
          }
          {
            name = "calculator";
            match = {
              class = "org.gnome.Calculator";
            };
            float = true;
          }
          {
            name = "idle-inhibit-class";
            match = {
              class = "^(.*)$";
            };
            idle_inhibit = "fullscreen";
          }
          {
            name = "idle-inhibit-title";
            match = {
              title = "^(.*)$";
            };
            idle_inhibit = "fullscreen";
          }
          {
            name = "idle-inhibit-fullscreen";
            match = {
              fullscreen = true;
            };
            idle_inhibit = "fullscreen";
          }
          {
            name = "suppress-maximize";
            match = {
              class = ".*";
            };
            suppress_event = "maximize";
          }
          {
            name = "fix-xwayland-drags";
            match = {
              class = "^$";
              title = "^$";
              xwayland = true;
              float = true;
              fullscreen = false;
              pin = false;
            };
            no_focus = true;
          }
          {
            name = "pip-float-pin";
            match = {
              title = "^(Picture-in-Picture)$";
            };
            float = true;
            pin = true;
          }
        ];

        layer_rule = [
          {
            name = "rofi";
            match = {
              namespace = "rofi";
            };
            dim_around = true;
            blur = true;
            ignore_alpha = 0;
          }
          {
            name = "logout-dialog";
            match = {
              namespace = "logout_dialog";
            };
            blur = true;
          }
          {
            name = "waybar";
            match = {
              namespace = "waybar";
            };
            blur = true;
            ignore_alpha = 0.5; # Prevents jagged looking non anti-aliased curved borders
            blur_popups = true;
          }
        ];
      };

      extraConfig = ''
        -- See https://wiki.hypr.land/Configuring/Binds/
        -- `wev` can be used to capture inputs to determine codes

        local mod = "SUPER"

        -- Programs to be launched on start-up (will not be relaunched on Hyprland reload)
        hl.on("hyprland.start", function()
          hl.exec_cmd("uwsm finalize")
          hl.exec_cmd("dbus-update-activation-environment --systemd PATH")
          hl.exec_cmd("systemctl --user start hyprpolkitagent")
          hl.exec_cmd("uwsm app -- hyprpaper")
          hl.exec_cmd("uwsm app -- kdeconnectd")
          hl.exec_cmd("${startup}/bin/startup")
        end)

        -- Float, resize and center windows whose title matches the configured list
        local popupHeightPct = ${toString popupHeightPercent}
        local popupWidthPct = ${toString popupWidthPercent}
        local popupTitles = ${popupTitles}

        hl.on("window.title", function(w)
          for _, title in ipairs(popupTitles) do
            if w.title == title then
              local mon = hl.get_active_monitor()
              if mon then
                local height = math.floor(mon.height * popupHeightPct / 100)
                local width = math.floor(mon.height * popupWidthPct / 100)
                hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
                hl.dispatch(hl.dsp.window.resize({ x = width, y = height, window = w }))
                hl.dispatch(hl.dsp.window.center({ window = w }))
              end
              break
            end
          end
        end)

        -- Close the launcher on workspace switches, ensure it is open on empty workspaces
        hl.on("workspace.active", function(ws)
          if ws.is_empty then
            hl.exec_cmd("launcher --open")
          else
            hl.exec_cmd("pkill -x rofi")
          end
        end)

        -- Dismiss the launcher when a new window opens
        hl.on("window.open", function()
          hl.exec_cmd("pkill -x rofi")
        end)

        hl.bind(mod .. " + W", hl.dsp.window.close())
        hl.bind(mod .. " + Q", hl.dsp.exec_cmd("kitty"))
        hl.bind(mod .. " + E", hl.dsp.exec_cmd("uwsm app -- nautilus"))
        hl.bind(mod .. " + T", hl.dsp.exec_cmd("uwsm app -- ghostty")) -- TODO: use terminal variable
        hl.bind(mod .. " + ALT + T", hl.dsp.exec_cmd("${ghosttyMist}/bin/ghostty-mist")) -- TODO: use terminal variable

        -- Move active window with mainMod + SHIFT + arrow keys
        hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
        hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
        hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
        hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

        hl.bind(mod .. " + ALT + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
        hl.bind(mod .. " + ALT + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
        hl.bind(mod .. " + ALT + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
        hl.bind(mod .. " + ALT + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

        -- Binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        for i = 0, 8 do
          hl.bind(mod .. " + code:1" .. i, hl.dsp.focus({ workspace = i + 1 }))
          hl.bind(mod .. " + SHIFT + code:1" .. i, hl.dsp.window.move({ workspace = i + 1 }))
          hl.bind(mod .. " + SHIFT + ALT + code:1" .. i, hl.dsp.window.move({ workspace = i + 1, follow = false }))
        end

        hl.bind(mod .. " + CTRL + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + V", function()
          local clipboardWindows = hl.get_windows({ class = "com.my.clipboard" })
          if #clipboardWindows > 0 then
            for _, w in ipairs(clipboardWindows) do
              hl.dispatch(hl.dsp.window.close({ window = w }))
            end
          else
            hl.exec_cmd("${clipboardManager}/bin/clipboardManager")
          end
        end)
        hl.bind(mod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

        -- Move focus with mainMod + arrow keys
        hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
        hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

        hl.bind(mod .. " + CTRL + SHIFT + 1", hl.dsp.workspace.move({ monitor = 0 }))
        hl.bind(mod .. " + CTRL + SHIFT + 2", hl.dsp.workspace.move({ monitor = 1 }))
        hl.bind(mod .. " + CTRL + SHIFT + 3", hl.dsp.workspace.move({ monitor = 2 }))

        -- Resize active window
        hl.bind(mod .. " + ALT + right", hl.dsp.window.resize({ x = 160, y = 0, relative = true }), { locked = true, repeating = true })
        hl.bind(mod .. " + ALT + left", hl.dsp.window.resize({ x = -160, y = 0, relative = true }), { locked = true, repeating = true })
        hl.bind(mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -90, relative = true }), { locked = true, repeating = true })
        hl.bind(mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 90, relative = true }), { locked = true, repeating = true })

        -- Example special workspace (scratchpad)
        hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
        hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))
        hl.bind(mod .. " + ALT + SHIFT + S", hl.dsp.window.move({ workspace = 1, follow = false }))

        -- Scroll through existing workspaces with mainMod + scroll
        hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

        -- Move/resize windows with mainMod + LMB/RMB and dragging
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
        hl.bind(mod .. " + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

        -- Custom binds
        hl.bind(mod .. " + C", hl.dsp.exec_cmd("${search}/bin/search"))
        hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen())
        hl.bind(mod .. " + F", hl.dsp.window.fullscreen_state({ internal = 1, client = 1 }))
        hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen_state({ internal = -1, client = 2 }))
        hl.bind(mod .. " + ESCAPE", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
        hl.bind(mod .. " + CTRL + ESCAPE", hl.dsp.exec_cmd("powerMenu"))

        -- Tap SUPER to open the launcher; holding it cancels the pending open
        local superCancelled = false

        hl.bind(mod .. " + SUPER_L", function()
          superCancelled = false
        end, { ignore_mods = true })

        hl.bind(mod .. " + SUPER_L", function()
          superCancelled = true
        end, { long_press = true, ignore_mods = true })

        hl.bind(mod .. " + SUPER_L", function()
          if not superCancelled then
            hl.exec_cmd("launcher")
          end
        end, { release = true })

        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"), { locked = true, repeating = true })
        hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
        hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
        -- Requires playerctl
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player playerctld play-pause"), { locked = true })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --player playerctld previous"), { locked = true })
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --player playerctld next"), { locked = true })

        -- Use play button to skip and back on laptop without dedicated keys
        hl.bind("SHIFT + XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player playerctld next"), { locked = true })
        hl.bind("ALT + XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player playerctld previous"), { locked = true })

        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("displayBrightness decrease"))
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("displayBrightness increase"))
        hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("displayBrightness min"))
        hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("displayBrightness max"))

        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e s 10%-"), { repeating = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e s +10%"), { repeating = true })
        hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e s 1%"), { repeating = true })
        hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e s +100%"), { repeating = true })

        -- Note: using QMK keyboard mic key is bound to F20 (XF86AudioMicMute) on layer 2 and F21 (XF86TouchpadOn) on layer 3
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("toggleMicrophone"))
        hl.bind("SHIFT + XF86AudioMute", hl.dsp.exec_cmd("cycleAudioOutput"))

        hl.bind(mod .. " + mouse:274", hl.dsp.window.close())

        hl.bind(mod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

        hl.bind("Print", hl.dsp.exec_cmd('hyprshot --mode region --output-folder "Pictures/Screenshots"'))
        hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot --mode region --clipboard-only"))
        hl.bind(mod .. " + Print", hl.dsp.exec_cmd('hyprshot --mode output --output-folder "Pictures/Screenshots"'))
        hl.bind("CTRL + Print", hl.dsp.exec_cmd('hyprshot --mode window --output-folder "Pictures/Screenshots"'))
        hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd("hyprshot --mode window --clipboard-only"))
        hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot --mode output --clipboard-only"))

        hl.bind(mod .. " + K", hl.dsp.exec_cmd("hyprctl kill"))


        hl.bind(mod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
        hl.bind(mod .. " + L", function()
          local layout = hl.get_config("general:layout")
          hl.config({ general = { layout = layout == "master" and "dwindle" or "master" } })
        end)
        hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("swapwithmaster master"))

        -- hl.bind(mod .. " + z", function()
        --   hl.config({ cursor = { zoom_factor = hl.get_config("cursor:zoom_factor") + 0.08 } })
        -- end)
        -- hl.bind(mod .. " + SHIFT + z", function()
        --   hl.config({ cursor = { zoom_factor = 1.0 } })
        -- end)
      '';
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock --grace 5"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"; # to avoid having to press a key twice to turn on the display.
        };
        listener = [
          {
            timeout = 600; # 10min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 1200; # 20min
            on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 20min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    programs = {
      hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
            grace = 5;
          };
          animations = {
            enabled = true;
            animation = [
              "fadeIn, 1, 20, linear"
              "fadeOut, 1, 4, linear"
            ];
          };
          background = [
            {
              path = wallpaperPath;
              blur_passes = 3;
              contrast = 0.8916;
              brightness = 0.8172;
              vibrancy = 0.1696;
              vibrancy_darkness = 0.0;
              blur_size = 8;
            }
          ];
          input-field = [
            {
              size = "320, 60";
              outline_thickness = "2";
              dots_size = "0.3"; # Scale of input-field height, 0.2 - 0.8
              dots_spacing = "0.8"; # Scale of dots' absolute size, 0.0 - 1.0
              dots_center = "true";
              outer_color = "transparent";
              inner_color = themeLib.asRGBA theme.color.white theme.opacity.elementLight;
              font_color = themeLib.asRGBA theme.color.white theme.opacity.elementHeavy;
              fade_on_empty = "true";
              font_family = "JetBrains Mono ExtraBold";
              hide_input = "false";
              position = "0, -120";
              halign = "center";
              valign = "center";
              capslock_color = "rgba(160, 120, 0, 0.3)";
              numlock_color = "rgba(160, 120, 0, 0.3)";
              check_color = "rgba(255, 255, 255, 0.3)";
              fail_color = "rgba(204, 34, 34, 0.5)";
              placeholder_text = "";
            }
          ];
          label = [
            {
              text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
              color = "rgba(255, 255, 255, 0.75)";
              font_size = "140";
              font_family = "JetBrains Mono ExtraBold";
              position = "0, 80";
              halign = "center";
              valign = "center";
            }
            {
              text = "cmd[update:1000] ${lockdown}/bin/lockdown $ATTEMPTS";
            }
          ];
        };
      };
      kitty.enable = true;
      hyprshot.enable = true;
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = [ "~/.local/share/wallpaper" ];
        wallpaper = wallpapers;
      };
    };

    home.packages = with pkgs; [
      networkmanagerapplet
      hyprpicker
      hyprpaper
      nerd-fonts.symbols-only
      jetbrains-mono
      overskride
      adwaita-fonts
    ];

    home.pointerCursor = {
      gtk.enable = true;
      hyprcursor.enable = true;
      package = pkgs.bibata-cursors;
      name = cursorName;
      size = cursorSize;
    };

    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":";
    dconf.settings."org/gnome/desktop/interface" = {
      gtk-enable-primary-paste = true;
      cursor-theme = cursorName;
      cursor-size = cursorSize;
    };

    fonts.fontconfig.enable = true;

    home.activation.setHyprlandCursor = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
      runtimeDir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

      signature="''${HYPRLAND_INSTANCE_SIGNATURE:-}"
      if [[ -z "$signature" ]]; then
        for socket in "$runtimeDir"/hypr/*/.socket.sock; do
          if [[ -S "$socket" ]]; then
            signature="$(basename "$(dirname "$socket")")"
            break
          fi
        done
      fi

      if [[ -n "$signature" && -S "$runtimeDir/hypr/$signature/.socket.sock" ]]; then
        env XDG_RUNTIME_DIR="$runtimeDir" HYPRLAND_INSTANCE_SIGNATURE="$signature" \
          ${pkgs.hyprland}/bin/hyprctl setcursor ${cursorName} ${toString cursorSize} || true
      fi

      env XDG_RUNTIME_DIR="$runtimeDir" ${pkgs.systemd}/bin/systemctl --user set-environment \
        XCURSOR_THEME=${cursorName} XCURSOR_SIZE=${toString cursorSize} \
        HYPRCURSOR_THEME=${cursorName} HYPRCURSOR_SIZE=${toString cursorSize} || true
    '';
  };
}
