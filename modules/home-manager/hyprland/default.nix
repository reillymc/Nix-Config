{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  # imports = [
  #   ./monitors.nix
  #   ./keymaps.nix
  #   ./start.nix
  # ];

  options = {
    myhome.hyprland.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.myhome.hyprland.enable {
    # myhome.waybar.enable = lib.mkDefault false;
    # myhome.ags.enable = lib.mkDefault true;
    # myhome.astalshell.enable = lib.mkDefault true;
    # myhome.hyprland.split-workspaces.enable = lib.mkDefault true;
    # myhome.keymap.enable = lib.mkDefault true;
    # myhome.start.enable = lib.mkDefault true;

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;

          layout = "master";
        };

        monitor = "DP-1, 5120x1440@118, 0x0, 1, bitdepth, 10";

        env = [
          "XCURSOR_SIZE,24"
        ];

        input = {
          follow_mouse = 1;
        };

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

        "$mod" = "SUPER";
        bind = [
          "$mod, W, killactive"
          "$mod, Q, exec, kitty"
          "$mod, E, exec, uwsm app -- nautilus"
          "$mod, T, exec, uwsm app -- blackbox"
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
              ]
            ) 9
          )
        );
      };
    };

    programs.kitty.enable = true;

    home.packages = with pkgs; [
      networkmanagerapplet
      rofi-wayland
    ];
  };
}
