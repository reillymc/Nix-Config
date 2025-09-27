{
  ...
}:
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "dark:Adwaita Dark,light:Adwaita";
      resize-overlay = "never";
      keybind = [
        "ctrl+v=paste_from_clipboard"
        "performable:ctrl+c=copy_to_clipboard"
      ];
    };
  };

  programs.bash = {
    enable = true;
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set completion-ignore-case on
    '';
  };
}
