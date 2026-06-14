{
  pkgs,
  config,
  lib,
  ...
}:
let
  themeLib = import ../../../lib/theme.nix { inherit lib; };
  theme = config.myhome.display.theme;

  globalProperties = ''
    * {
        background:     ${themeLib.withAlpha theme.color.background0 theme.opacity.overlay};
        surface:        ${themeLib.withAlpha theme.color.background1 theme.opacity.elementHeavy};
        surfaceSelected: ${theme.color.accentPrimary0};
        foreground:     ${theme.color.foreground0};
        font: "JetBrains Mono Nerd Font SemiBold 10";
    }
  '';

  windowProperties = ''
    window {
        transparency:                "real";
        border-radius:               ${themeLib.asPixels theme.radii.loose};
        background-color:            @background;
    }
  '';

  launcher = pkgs.writeShellScriptBin "launcher" ''
    monitorHeight=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .height')
    targetHeight=$((monitorHeight * ${toString (themeLib.toPercentInt theme.size.popup.regular.height)} / 100))
    targetWidth=$((monitorHeight * ${toString (themeLib.toPercentInt theme.size.popup.regular.width)} / 100))

    pkill rofi || rofi -show drun -config ~/.config/rofi/config.rasi -theme-str "window { height: ''${targetHeight}px; width: ''${targetWidth}px; }"
  '';

  powerMenu = pkgs.writeShellScriptBin "powerMenu" ''
    monitorHeight=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .height')
    targetHeight=$((monitorHeight * ${toString (themeLib.toPercentInt theme.size.popup.regular.height)} / 100))
    targetWidth=$((monitorHeight * ${toString (themeLib.toPercentInt theme.size.popup.regular.width)} / 100))


    options="󰤄\n\n󰗽\n"
    chosen=$(echo -e "$options" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi -theme-str "window { height: ''${targetHeight}px; width: ''${targetWidth}px; }")
    case "$chosen" in
      "󰤄")
        systemctl suspend
        ;;
      "󰗽")
        hyprctl dispatch exit
        ;;
      "")
        systemctl reboot
        ;;
      "")
        systemctl poweroff
        ;;
    esac
  '';
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = with pkgs; [
      rofi-emoji
      rofi-calc
    ];
  };

  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi:                       "drun,filebrowser,window,emoji,ssh,calc";
      show-icons:                 true;
      display-drun:               "";
      display-filebrowser:        "";
      display-window:             "󰣆";
      display-emoji:              "󰱨";
      display-ssh:                "";
      display-calc:               "";
      drun-display-format:        "{name}";
      window-format:              "{w} · {c} · {t}";
      terminal:                   "ghostty";

      font: "JetBrains Mono 10";

      sorting-method: "normal";
      case-sensitive: false;
      scroll-method: 0;

      kb-move-char-back: "Control+b";
      kb-move-char-forward: "Control+f";
      kb-mode-next: "Right,Control+Tab";
      kb-mode-previous: "Left";

      drun-match-fields:
        "name,generic,comment,categories,keywords";

      filebrowser {
        directories-first: true;
        sorting-method: "name";
      }

      calc {
        hint-result: "";
        hint-welcome: "";
      }
    }

    @theme "theme.rasi"
  '';

  xdg.configFile."rofi/theme.rasi".text = ''
    ${globalProperties}
    ${windowProperties}

    /*****----- Main Box -----*****/
    mainbox {
        enabled:                     true;
        spacing:                     8px;
        margin:                      0px;
        padding:                     24px;
        border:                      0px solid;
        background-color:            transparent;
        children:                    [ "inputbar", "message", "listview" ];
    }

    /*****----- Inputbar -----*****/
    inputbar {
        enabled:                     true;
        background-color:            transparent;
        text-color:                  @foreground;
        margin:                      0 0 15px 0;
        spacing:                     0px;
        children:                    [ "textbox-prompt-colon", "entry", "mode-switcher" ];
    }

    prompt {
        enabled:                     true;
        background-color:            inherit;
        text-color:                  inherit;
    }
    textbox-prompt-colon {
        vertical-align:              0.5;
        padding:                     0 0 0 18px;
        expand:                      false;
        str:                         "";
        font: "JetBrains Mono Nerd Font Bold 11";
        background-color:            @surface;
        text-color:                  inherit;
        border-radius:               ${themeLib.asPixels theme.radii.pill} 0 0 ${themeLib.asPixels theme.radii.pill};
    }
    entry {
        enabled:                     true;
        vertical-align:              0.5;
        background-color:            inherit;
        padding:                     12px;
        font: "JetBrains Mono Nerd Font Bold 11";
        text-color:                  inherit;
        cursor:                      text;
        placeholder:                 "Search...";
        placeholder-color:           inherit;
        background-color:            @surface;
        border-radius:               0 ${themeLib.asPixels theme.radii.pill} ${themeLib.asPixels theme.radii.pill} 0;
        margin:                      0 5px 0 0;
    }
    num-filtered-rows {
        enabled:                     true;
        expand:                      false;
        background-color:            inherit;
        text-color:                  inherit;
    }
    textbox-num-sep {
        enabled:                     true;
        expand:                      false;
        str:                         "/";
        background-color:            inherit;
        text-color:                  inherit;
    }
    num-rows {
        enabled:                     true;
        expand:                      false;
        background-color:            inherit;
        text-color:                  inherit;
    }
    case-indicator {
        enabled:                     true;
        background-color:            inherit;
        text-color:                  inherit;
    }

    /*****----- Listview -----*****/
    listview {
        enabled:                     true;
        columns:                     1;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   true;
        layout:                      vertical;
        spacing:                     5px;
        background-color:            inherit;
        text-color:                  inherit;
    }
    scrollbar {
        handle-width:                6px;
        handle-color:                @surfaceSelected;
        border-radius:               50%;
        background-color:            @surface;
        handle-rounded-corners: true;
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        padding:                     6px 8px;
        border-radius:               ${themeLib.asPixels theme.radii.soft};
        cursor:                      pointer;
        background-color:            @surface;
        text-color:                  @foreground;
    }
    element selected.normal {
        background-color:            @surfaceSelected;
        text-color:                  ${theme.color.background1};
    }

    element-icon {
        background-color:            transparent;
        text-color:                  inherit;
        size:                        26px;
        padding:                     4px;
        cursor:                      inherit;
    }
    element-text {
        background-color:            transparent;
        text-color:                  inherit;
        highlight:                   inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.0;
    }

    /*****----- Mode Switcher -----*****/
    mode-switcher{
        enabled:                     true;
        spacing:                     5px;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px;
        background-color:            transparent;
        text-color:                  @foreground;
    }
    button {
        padding:                     5px;
        border:                      0px solid;
        border-radius:               ${themeLib.asPixels theme.radii.pill};
        background-color:            @surface;
        text-color:                  inherit;
        cursor:                      pointer;
        width: 40px;
    }
    button selected {
        background-color:            @surfaceSelected;
        text-color:                  ${theme.color.background1};
    }

    /*****----- Message -----*****/
    message {
        enabled:                     true;
        margin:                      5px 12px 14px 12px;
        background-color:            transparent;
        text-color:                  @foreground;
    }
    textbox {
        background-color:            inherit;
        text-color:                  @foreground;
        horizontal-align:            0.5;
        vertical-align:              0.5;
        padding: 4px 0px;
    }
    error-message {
        background-color:            transparent;
        text-color:                  inherit;
    }
  '';

  xdg.configFile."rofi/powermenu.rasi".text = ''
    configuration {
      font: "JetBrains Mono SemiBold 10";
    }

    @theme "powermenu-theme.rasi"
  '';

  xdg.configFile."rofi/powermenu-theme.rasi".text = ''
    ${globalProperties}
    ${windowProperties}

    mainbox {
        children: [ "listview" ];
        padding: 24px;
        background-color: transparent;
    }

    listview {
        columns: 2;
        cycle: true;
        expand: true;
        scrollbar: false;
        spacing: 24px;
        background-color: transparent;
    }

    element {
        children: [ "element-text" ];
        border-radius: ${themeLib.asPixels theme.radii.round};
        background-color:            @surface;
        text-color:                  @foreground;
        cursor: pointer;
        padding: 100px 0 100px 0;
        expand: true;
    }

    element selected.normal {
        background-color: @surfaceSelected;
        text-color: ${theme.color.background1};
    }

    element-text {
        expand: true;
        horizontal-align: 0.5;
        vertical-align: 0.5;
        cursor: pointer;
        padding: 24px;
        text-color: @foreground;
        background-color: transparent;
        font: "JetBrains Mono Nerd Font SemiBold 48";
    }

    element-text selected.normal{
        text-color: ${theme.color.background1};
    }
  '';

  home.packages = [
    launcher
    powerMenu
  ];
}
