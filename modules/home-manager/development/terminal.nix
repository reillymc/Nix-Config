{
  config,
  ...
}:
let
  theme = config.myhome.display.theme;
in
{
  programs = {
    ghostty = {
      enable = true;
      settings = {
        theme = "dark:Adwaita Dark,light:Adwaita";
        resize-overlay = "never";
        background-opacity = toString theme.opacity.overlay;
        keybind = [
          "ctrl+v=paste_from_clipboard"
          "performable:ctrl+c=copy_to_clipboard"
          "performable:ctrl+t=new_tab"
          "performable:ctrl+w=close_tab"
        ];
        cursor-click-to-move = false;
        selection-clear-on-copy = true;
        shell-integration = "detect";
      };
    };
    bash = {
      enable = true;
    };
    readline = {
      enable = true;
      extraConfig = ''
        set completion-ignore-case on
      '';
    };
  };
}
