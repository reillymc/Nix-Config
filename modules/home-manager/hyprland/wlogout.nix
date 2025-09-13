{
  ...
}:
{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        "label" = "shutdown";
        "action" = "systemctl poweroff";
        "text" = "";
        "keybind" = "s";
      }
      {
        "label" = "reboot";
        "action" = "systemctl reboot";
        "text" = "";
        "keybind" = "r";
      }
      {
        "label" = "logout";
        "action" = "hyprctl dispatch exit";
        "text" = "󰗽";
        "keybind" = "e";
      }
      {
        "label" = "suspend";
        "action" = "loginctl lock-session & sleep 1 ; systemctl suspend";
        "text" = "󰤄";
        "keybind" = "h";
      }
    ];
    style = ''
      * {
          background-image: none;
          font-size: 80px;
          font-family: "JetBrains Mono", "Symbols Nerd Font Mono";
          font-weight: 600;
      }

      window {
          background-color: alpha(#000, 0.5);
      }

      button {
          color: @background;
          background-color: alpha(#000, 0.75);
          border: none;
          border-radius: 48px;
          padding-bottom: 72px;
          outline: none;
          box-shadow: none;
          text-shadow: none;
          transition: all 0.3s cubic-bezier(0.55, 0, 0.28, 1.682);
      }

      button:focus {
          background-color: alpha(#fff, 0.75);
      }

      button:hover {
          background-color: alpha(#fff, 0.75);
      }
    '';
  };
}
