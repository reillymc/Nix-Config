{
  lib,
  config,
  ...
}:
let
  cfg = config.mynixos.ly;
in
{
  options = {
    mynixos.ly.enable = lib.mkEnableOption "ly display manager";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
        load = true;
        save = true;
        allow_empty_password = false;
        animation = "none";
        asterisk = "0x2022";
        brightness_down_key = null;
        brightness_up_key = null;
        clear_password = true;
        hide_version_string = true;
        default_input = "password";
        session = "hyprland-uwsm";
        session_log = null;
      };
    };
  };
}
