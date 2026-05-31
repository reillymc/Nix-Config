{
  pkgs,
  config,
  mynixos,
  lib,
  theme,
  ...
}:
let
  monitorConfigs = map (
    mon:
    let
      bitdepthStr = if mon.bitdepth != null then ", bitdepth, ${toString mon.bitdepth}" else "";
    in
    "${mon.output}, ${mon.resolution}@${toString mon.refreshRate}, ${mon.position}, ${toString mon.scale}${bitdepthStr}"
  ) config.myhome.display.monitors;

  wallpaperPath = if theme == "light" then "~/.cache/wallpaper" else "~/.cache/wallpaper-dark";

  wallpapers = map (mon: {
    monitor = mon.output;
    path = wallpaperPath;
    fit_mode = "cover";
  }) config.myhome.display.monitors;

  lockdown = pkgs.writeShellScriptBin "lockdown" ''
    if (($1 > 3)); then
      hyprctl dispatch exit
    fi
  '';

  toggleLayout = pkgs.writeShellScriptBin "toggleLayout" ''
    layout=$(hyprctl -j getoption general:layout | grep '"str"' | sed -E 's/.*"str": ?"([^"]+)".*/\1/')
    case "$layout" in
      dwindle) hyprctl keyword general:layout master ;;
      master)  hyprctl keyword general:layout dwindle ;;
    esac
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

  launcher = pkgs.writeShellScriptBin "launcher" ''
    pkill rofi || rofi -show drun -config ~/.config/rofi/config.rasi
  '';

  clipboardManager = pkgs.writeShellScriptBin "clipboardManager" ''
    output=$(hyprctl dispatch killwindow class:com.my.clipboard 2>&1)
    status=$?

    if [[ $status -ne 0 || "$output" == *"no window found"* ]]; then
        ghostty --class=com.my.clipboard -e clipse
    fi
  '';
in
{
  imports = [
    ./waybar.nix
    ./wlogout.nix
    ./clipse.nix
    ./rofi.nix
    ./swaync.nix
    ./audio.nix
  ];

  config = lib.mkIf mynixos.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang"; # TODO: migrate to LUA (home manager may have better support inj a few releases)
      systemd.enable = false;
      settings = {
        general = {
          gaps_in = 3;
          gaps_out = 6;
          border_size = 0;

          layout = "master"; # TODO: hy3
        };

        monitor = monitorConfigs;

        env = [
          "XCURSOR_SIZE,24"
        ];

        input = {
          follow_mouse = 1;
          kb_layout = "us";
          touchpad = {
            natural_scroll = true;
            clickfinger_behavior = true;
            disable_while_typing = false;
          };
        };

        gesture = [
          "3, pinch, fullscreen, maximise"
          "3, swipe, scale: 1.25, resize"
          "4, pinchin, dispatcher, exec, ${launcher}/bin/launcher"
          "4, pinchout, dispatcher, exec, pkill rofi || hyprctl dispatch killactive"
          "4, horizontal, workspace"
          "4, vertical, special, magic"
        ];

        misc = {
          force_default_wallpaper = 0;
        };

        binds = {
          movefocus_cycles_fullscreen = 0;
        };

        animations = {
          enabled = true;

          bezier = "myBezier, 0.25, 0.9, 0.1, 1.02";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
          ];
        };

        cursor = {
          inactive_timeout = 5;
          no_hardware_cursors = true; # temporary workaround for cursor not changing to proper glyph after unstable switch
        };

        # See https://wiki.hyprland.org/Configuring/Binds/
        "$mod" = "SUPER";
        bind = [
          "$mod, W, killactive"
          "$mod, Q, exec, kitty"
          "$mod, E, exec, uwsm app -- nautilus"
          "$mod, T, exec, uwsm app -- ghostty" # TODO: use terminal variable
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"
          "$mod ALT SHIFT, left, swapwindow, l"
          "$mod ALT SHIFT, right, swapwindow, r"
          "$mod ALT SHIFT, up, swapwindow, u"
          "$mod ALT SHIFT, down, swapwindow, d"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                "$mod SHIFT ALT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
              ]
            ) 9
          )
        );
      };

      extraConfig = ''
        # Programs to be launched on start-up (will not be relaunched on Hyprland reload)
        exec-once = dbus-update-activation-environment --systemd PATH
        exec-once = systemctl --user start hyprpolkitagent

        exec-once = uwsm app -- hyprpaper
        exec-once = uwsm app -- kdeconnectd
        exec-once = ${startup}/bin/startup
        exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhy3.so"


        # See https://wiki.hyprland.org/Configuring/Binds/
        # `wev` can be used to capture inputs to determine codes
        $mainMod = SUPER

        bind = $mainMod CTRL SHIFT, F, togglefloating,
        bind = $mainMod, V, exec, ${clipboardManager}/bin/clipboardManager
        bind = $mainMod, J, togglesplit, # dwindle

        # Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l #hy3:
        bind = $mainMod, right, movefocus, r #hy3:
        bind = $mainMod, up, movefocus, u #hy3:
        bind = $mainMod, down, movefocus, d #hy3:

        bind = $mainMod CTRL SHIFT, 1, movecurrentworkspacetomonitor, 0
        bind = $mainMod CTRL SHIFT, 2, movecurrentworkspacetomonitor, 1
        bind = $mainMod CTRL SHIFT, 3, movecurrentworkspacetomonitor, 2


        # Resize active window
        bindel = $mainMod ALT, right, resizeactive, 160 0
        bindel = $mainMod ALT, left, resizeactive, -160 0
        bindel = $mainMod ALT, up, resizeactive, 0 -90
        bindel = $mainMod ALT, down, resizeactive, 0 90

        # Move active window
        bind = $mainMod SHIFT, left, movewindow, l #hy3:
        bind = $mainMod SHIFT, right, movewindow, r #hy3:
        bind = $mainMod SHIFT, up, movewindow, u #hy3:
        bind = $mainMod SHIFT, down, movewindow, d #hy3:

        bind = $mainMod ALT SHIFT, left, swapwindow, l
        bind = $mainMod ALT SHIFT, right, swapwindow, r
        bind = $mainMod ALT SHIFT, up, swapwindow, u
        bind = $mainMod ALT SHIFT, down, swapwindow, d

        # Example special workspace (scratchpad)
        bind = $mainMod, S, togglespecialworkspace, magic
        bind = $mainMod SHIFT, S, movetoworkspacesilent, special:magic
        bind = $mainMod ALT SHIFT, S, movetoworkspacesilent, 1

        # Scroll through existing workspaces with mainMod + scroll
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
        bindm = $mainMod ALT, mouse:272, resizewindow

        # Custom binds
        bind = $mainMod, C, exec, ${search}/bin/search
        bind = $mainMod SHIFT, F, fullscreen
        bind = $mainMod, F, fullscreenstate, 1 1
        bind = $mainMod ALT, F, fullscreenstate, -1 2
        bind = $mainMod, ESCAPE, exec, pidof hyprlock || hyprlock
        # bind = $mainMod, ESCAPE, exec, swaylock
        bind = $mainMod CTRL, ESCAPE, exec, logoutMenu

        bindr = $mainMod, SUPER_L, exec, ${launcher}/bin/launcher

        bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+
        bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-
        bindel = SHIFT, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        bindel = SHIFT, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        # Requires playerctl
        bindl = , XF86AudioPlay, exec, playerctl --player playerctld play-pause
        bindl = , XF86AudioPrev, exec, playerctl --player playerctld previous
        bindl = , XF86AudioNext, exec, playerctl --player playerctld next

        # Use play button to skip and back on laptop without dedicated keys
        bindl = SHIFT, XF86AudioPlay, exec, playerctl --player playerctld next
        bindl = ALT, XF86AudioPlay, exec, playerctl --player playerctld previous

        bind = ,XF86MonBrightnessDown,exec, displayBrightness min
        bind = ,XF86MonBrightnessUp, exec, displayBrightness max
        bind = SHIFT,XF86MonBrightnessDown,exec, displayBrightness decrease
        bind = SHIFT,XF86MonBrightnessUp, exec, displayBrightness increase

        binde = ,XF86MonBrightnessDown, exec, brightnessctl -e s 10%-
        binde = ,XF86MonBrightnessUp, exec, brightnessctl -e s +10%
        binde = SHIFT,XF86MonBrightnessDown, exec, brightnessctl -e s 1%
        binde = SHIFT,XF86MonBrightnessUp, exec, brightnessctl -e s +100%

        # Note: using QMK keyboard mic key is bound to F20 (XF86AudioMicMute) on layer 2 and F21 (XF86TouchpadOn) on layer 3
        bind = , XF86AudioMicMute, exec, toggleMicrophone
        bind = SHIFT, XF86AudioMute, exec, cycleAudioOutput

        bind = $mainMod, mouse:274, killactive

        bind = $mainMod, N, exec, swaync-client -t

        bind = , Print, exec, hyprshot --mode region --output-folder "Pictures/Screenshots"
        bind = SHIFT, Print, exec, hyprshot --mode region --clipboard-only
        bind = $mainMod, Print, exec, hyprshot --mode output --output-folder "Pictures/Screenshots"
        bind = CTRL, Print, exec, hyprshot --mode window --output-folder "Pictures/Screenshots"
        bind = CTRL SHIFT, Print, exec, hyprshot --mode window --clipboard-only
        bind = $mainMod SHIFT, Print, exec, hyprshot --mode output --clipboard-only

        bind = $mainMod, K, exec, hyprctl kill



        bind = $mainMod, P, exec, hyprpicker -a
        # bind = $mainMod, L, layoutmsg, swapwithmaster master
        bind = $mainMod, L, exec, ${toggleLayout}/bin/toggleLayout
        bind = $mainMod SHIFT, L, layoutmsg, swapwithmaster master

        bind=$mainMod,z,exec,hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 + 0.08}')
        bind=$mainMod SHIFT,z,exec,hyprctl keyword cursor:zoom_factor 1.0



        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules
        windowrule = opacity 0.8, match:class com.mitchellh.ghostty

        windowrule = float yes, match:class com.my.clipboard
        windowrule = size 622 652, match:class com.my.clipboard
        windowrule = stay_focused on, match:class com.my.clipboard
        windowrule = animation popin, match:class com.my.clipboard
        windowrule = opacity 0.8, match:class com.my.clipboard
        windowrule = stay_focused on, match:modal true

        windowrule = opacity 1, match:initial_title Picture-in-Picture

        windowrule = float yes, match:class org.gnome.NautilusPreviewer
        windowrule = size 1024 1024, match:class org.gnome.NautilusPreviewer

        windowrule = float yes, match:class org.gnome.Calculator

        # prevent hypridle locking screen when any program is fullscreen - TODO: only fullscreen - not fullscreen mode with waybar
        windowrule = idle_inhibit fullscreen, match:class ^(.*)$
        windowrule = idle_inhibit fullscreen, match:title ^(.*)$
        windowrule = idle_inhibit fullscreen, match:fullscreen true

        # keep floating window always force focussed
        # windowrule = stay_focused on, match:float true

        layerrule = dim_around on,match:namespace rofi
        layerrule = blur on,match:namespace rofi
        layerrule = ignore_alpha 0,match:namespace rofi

        layerrule = blur on,match:namespace logout_dialog

        # layerrule = blur on,match:namespace waybar
        layerrule = ignore_alpha 0,match:namespace waybar

        # Ignore maximize requests from apps. You'll probably like this.
        windowrule = suppress_event maximize, match:class .*

        # Fix some dragging issues with XWayland
        windowrule = no_focus on, match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pin false

        windowrule = float yes, match:title ^(Picture-in-Picture)$
        windowrule = pin on, match:title ^(Picture-in-Picture)$

        # Remove borders when an application is maximised fullscreen (not complete fullscreen)
        workspace=f[1],rounding:false,bordersize:0,gapsout:0

        workspace = w[tv2], layoutopt:orientation:left

        # TODO: for laptop, work out if requred and make configurable if so
        # workspace = m[eDP-1]w[tv1], layoutopt:orientation:left

        workspace = m[eDP-1], layout:dwindle


        ${builtins.concatStringsSep "\n  " (
          map (
            mon: "workspace = w[t1]f[-1]m[${mon.output}], gapsout:6, gapsin:0"
          ) config.myhome.display.monitors
        )}
        workspace = w[t1]m[n], gapsout:6 1024, gapsin:0
        workspace = w[tg1], gapsout:6 6, gapsin:0
        # workspace = f[1], gapsout:6 6, gapsin:0


        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        # See https://wiki.hyprland.org/Configuring/Variables/#decoration for more
        decoration {
            rounding = 16
            inactive_opacity = 0.8

            blur {
                size = 12
                passes = 2
                new_optimizations = true
                ignore_opacity = true
                noise = 0.05
                brightness = 1.0
            }

            shadow {
                enabled = true
                range = 16
                color = 0x1a1a1a1a
            }
        }

        # debug:overlay = true

        # See https://wiki.hyprland.org/Configuring/Animations/ for more
        animations {
            enabled = true

            bezier = easeOutQuintSpring,0.23,1,0.32,1.03
            bezier = linear,0,0,1,1
            bezier = almostLinear,0.5,0.5,0.75,1.0
            bezier = easeOut,0, 0.55, 0.45, 1
            bezier = quick,0.15,0,0.1,1

            animation = global, 1, 10, default

            animation = windows, 1, 4.79, easeOutQuintSpring
            animation = windowsIn, 1, 4.1, easeOutQuintSpring
            animation = windowsOut, 1, 4.1, easeOutQuintSpring

            animation = layers, 1, 3.81, linear
            animation = layersIn, 1, 1.6, easeOut, fade, popin 90%
            animation = layersOut, 1, 0.42, quick, fade
            animation = fadeLayersIn, 1, 1.8, almostLinear
            animation = fadeLayersOut, 1, 1, almostLinear

            animation = fadeIn, 1, 2.05, almostLinear
            animation = fadeOut, 1, 1.46, almostLinear
            animation = fade, 1, 3.03, quick

            animation = workspaces, 1, 2.5, easeOutQuintSpring, slide
            animation = workspacesIn, 1, 2, easeOutQuintSpring, slide
            animation = workspacesOut, 1, 2.5, easeOutQuintSpring, slide

            animation = specialWorkspaceIn, 1, 4, easeOutQuintSpring, slidefadevert
            animation = specialWorkspaceOut, 1, 4, easeOutQuintSpring, slidefadevert
        }

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle {
            preserve_split = yes # you probably want this
        }

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master {
            # new_status = master
            orientation = center
            mfact = 0.5
            always_keep_position = true
            slave_count_for_center_master = 0
            allow_small_split = true
        }
        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc {
            force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
            disable_splash_rendering = true
            disable_hyprland_logo = true
            # animate_manual_resizes = true
        }

        group {
            groupbar {
                font_weight_active = bold
                indicator_height = 0
                gradient_rounding = 8
                col.active = 0xff000000
                col.inactive = 0xaa000000
                gradients = true
                gaps_in = 0
                gaps_out = 4
                keep_upper_gap = false
            }
        }

        plugin {
          hy3 {
            # disable gaps when only one window is onscreen
            # 0 - always show gaps
            # 1 - hide gaps with a single window onscreen
            # 2 - 1 but also show the window border
            no_gaps_when_only = 0 # default: 0


            # autotiling settings
            autotile {
              # enable autotile
              enable = true # default: false

              # make autotile-created groups ephemeral
            #   ephemeral_groups = <bool> # default: true

              # if a window would be squished smaller than this width, a vertical split will be created
              # -1 = never automatically split vertically
              # 0 = always automatically split vertically
              # <number> = pixel width to split at
              trigger_width = 1600 # default: 0

              # if a window would be squished smaller than this height, a horizontal split will be created
              # -1 = never automatically split horizontally
              # 0 = always automatically split horizontally
              # <number> = pixel height to split at
            #   trigger_height = <int> # default: 0

              # a space or comma separated list of workspace ids where autotile should be enabled
              # it's possible to create an exception rule by prefixing the definition with "not:"
              # workspaces = 1,2 # autotiling will only be enabled on workspaces 1 and 2
              # workspaces = not:1,2 # autotiling will be enabled on all workspaces except 1 and 2
            #   workspaces = <string> # default: all
            }
          }
        }
      '';
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };
        listener = [
          {
            timeout = 600; # 10min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 1200; # 20min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 20min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };
        animations = {
          enabled = true;
          fade_in = {
            duration = 1000;
            bezier = "easeOutQuint";
          };
          fade_out = {
            duration = 1000;
            bezier = "easeOutQuint";
          };
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
            outer_color = "rgba(0, 0, 0, 0)"; # TODO: colors from style system
            inner_color = "rgba(0, 0, 0, 0.5)";
            font_color = "rgb(200, 200, 200)";
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

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = [ "~/.cache/wallpaper" ];
        wallpaper = wallpapers;
      };
    };

    programs.kitty.enable = true;
    programs.hyprshot.enable = true;

    home.packages = with pkgs; [
      networkmanagerapplet
      hyprpicker
      hyprpaper
      nerd-fonts.symbols-only
      jetbrains-mono
      overskride
      adwaita-fonts
    ];

    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":";

    fonts.fontconfig.enable = true;

    systemd.user.services.switchToDarkCursor = {
      Unit = {
        Description = "Switch to dark cursor (hyprland)";
      };
      Service = {
        ExecStart = "${pkgs.hyprland}/bin/hyprctl setcursor Bibata-Modern-Ice 24";
        Type = "oneshot";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    systemd.user.services.switchToLightCursor = {
      Unit = {
        Description = "Switch to light cursor (hyprland)";
      };
      Service = {
        ExecStart = "${pkgs.hyprland}/bin/hyprctl setcursor Bibata-Modern-Classic 24";
        Type = "oneshot";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    systemd.user.timers.switchToDarkCursor = lib.mkIf (config.myhome.display.theme.darkTime != null) {
      Unit = {
        Description = "Timer to switch to dark cursor (hyprland)";
      };
      Timer = {
        OnCalendar = "*-*-* ${config.myhome.display.theme.darkTime}:00";
        Unit = "switchToDarkCursor.service";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    systemd.user.timers.switchToLightCursor = lib.mkIf (config.myhome.display.theme.lightTime != null) {
      Unit = {
        Description = "Timer to switch to light cursor (hyprland)";
      };
      Timer = {
        OnCalendar = "*-*-* ${config.myhome.display.theme.lightTime}:00";
        Unit = "switchToLightCursor.service";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
