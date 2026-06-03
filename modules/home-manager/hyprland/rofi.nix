{
  pkgs,
  ...
}:
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

      show-icons: true;
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
    /*****----- Global Properties -----*****/
    * {
        background:     #00000088;
        background-alt: #00000066;
        foreground:     #ffffff;
        selected:       #ffffffaa;
        active:         #ffffff55;
        urgent:         #ffffff55;
        
        font: "JetBrains Mono Nerd Font SemiBold 10";

        border-colour:               var(selected);
        handle-colour:               var(selected);
        background-colour:           var(background);
        foreground-colour:           var(foreground);
        alternate-background:        var(background-alt);
        normal-background:           var(background);
        normal-foreground:           var(foreground);
        urgent-background:           var(urgent);
        urgent-foreground:           var(background);
        active-background:           var(active);
        active-foreground:           var(background);
        selected-normal-background:  var(selected);
        selected-normal-foreground:  var(background);
        selected-urgent-background:  var(active);
        selected-urgent-foreground:  var(background);
        selected-active-background:  var(urgent);
        selected-active-foreground:  var(background);
    }

    /*****----- Main Window -----*****/
    window {
        /* properties for window widget */
        transparency:                "real";
        fullscreen:                  false;
        width:                       720;
        height:                      50%;

        /* properties for all widgets */
        enabled:                     true;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               16px;
        background-color:            @background-colour;
    }

    /*****----- Main Box -----*****/
    mainbox {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     24px;
        border:                      0px solid;
        background-color:            transparent;
        children:                    [ "inputbar", "message", "listview" ];
    }

    /*****----- Inputbar -----*****/
    inputbar {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0 10px 5px 10px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @border-colour;
        background-color:            transparent;
        text-color:                  @foreground-colour;
        children:                    [ "textbox-prompt-colon", "entry", "mode-switcher" ];
    }

    prompt {
        enabled:                     true;
        background-color:            inherit;
        text-color:                  inherit;
    }
    textbox-prompt-colon {
        vertical-align:              0.5;
        expand:                      false;
        str:                         "";
        background-color:            inherit;
        text-color:                  inherit;
    }
    entry {
        enabled:                     true;
        padding:                     8px 0px;
        background-color:            inherit;
        text-color:                  inherit;
        cursor:                      text;
        placeholder:                 "Search...";
        placeholder-color:           inherit;
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
        spacing:                     4px;
        background-color:            inherit;
        text-color:                  inherit;
    }
    scrollbar {
        handle-width:                4px ;
        handle-color:                @handle-colour;
        border-radius:               4px;
        background-color:            @alternate-background;
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        padding:                     6px 8px;
        border-radius:               12px;
        cursor:                      pointer;
        background-color:            var(normal-background);
        text-color:                  var(normal-foreground);
    }
    element urgent {
        background-color:            var(urgent-background);
        text-color:                  var(urgent-foreground);
    }
    element active {
        background-color:            var(active-background);
        text-color:                  var(active-foreground);
    }
    element selected.normal {
        background-color:            var(selected-normal-background);
        text-color:                  var(selected-normal-foreground);
    }
    element selected.urgent {
        background-color:            var(selected-urgent-background);
        text-color:                  var(selected-urgent-foreground);
    }
    element selected.active {
        background-color:            var(selected-active-background);
        text-color:                  var(selected-active-foreground);
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
        spacing:                     10px;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @border-colour;
        background-color:            transparent;
        text-color:                  @foreground-colour;
    }
    button {
        padding:                     5px;
        border:                      0px solid;
        border-radius:               12px;
        border-color:                @border-colour;
        background-color:            @alternate-background;
        text-color:                  inherit;
        cursor:                      pointer;
        width: 40px;
    }
    button selected {
        background-color:            var(selected-normal-background);
        text-color:                  var(selected-normal-foreground);
    }

    /*****----- Message -----*****/
    message {
        enabled:                     true;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px 0px 0px 0px;
        border-color:                @border-colour;
        background-color:            transparent;
        text-color:                  @foreground-colour;
    }
    textbox {
        background-color:            inherit;
        text-color:                  @foreground-colour;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }
    error-message {
        background-color:            transparent;
        text-color:                  inherit;
    }
  '';
}
