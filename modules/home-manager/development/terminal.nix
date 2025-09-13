{
  ...
}:
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "dark:Adwaita-dark,light:Adwaita";
      resize-overlay = "never";
      keybind = [
        "ctrl+v=paste_from_clipboard"
        "performable:ctrl+c=copy_to_clipboard"
      ];
    };
  };
}
