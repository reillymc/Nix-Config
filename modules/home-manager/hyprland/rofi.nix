{
  pkgs,
  configDir,
  ...
}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    modes = [ "drun" ];
    font = "JetBrains Mono 10";
    plugins = with pkgs; [
      rofi-emoji
      rofi-calc
    ];
    extraConfig = {
      show-icons = true;
      sorting-method = "normal";
      case-sensitive = false;
      scroll-method = 0;
      kb-move-char-back = "Control+b";
      kb-move-char-forward = "Control+f";
      kb-mode-next = "Right,Control+Tab";
      kb-mode-previous = "Left";
      # timeout = {
      #   action = "kb-cancel";
      #   delay = 0;
      # };
      # filebrowser = {
      #   directories-first = true;
      #   sorting-method = "name";
      # };
    };
    theme = "${configDir}/resources/rofi_theme.rasi";
  };
}
