{
  pkgs,
  ...
}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland; # TODO: remove when rofi 2.0.0 is available (native wayland support merged)
    modes = [ "drun" ];
    font = "JetBrains Mono 10";
    # plugins = [
    #   pkgs.rofi-emoji
    #   pkgs.rofi-calc
    # ];
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
    theme = "/home/reilly/.dotfiles/resources/rofi_theme.rasi";
  };
}
