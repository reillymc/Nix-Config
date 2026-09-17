{
  config,
  lib,
  pkgs,
  theme ? "dark",
  ...
}:
let
  mode = config.myhome.display.theme.mode;
  themeName = if mode == "light" then "Adwaita" else "Adwaita-dark";
  colorScheme = if mode == "light" then "prefer-light" else "prefer-dark";
in
{
  options.myhome.display.theme = lib.mkOption {
    type = lib.types.attrs;
    default = import ../theme { mode = theme; };
    description = "Object containing active theme";
  };

  config = {
    dconf.enable = true;
    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = colorScheme;
      gtk-theme = themeName;
    };

    gtk = {
      enable = true;

      theme = {
        name = themeName;
        package = pkgs.gnome-themes-extra;
      };
      gtk4.theme = null;
    };
  };
}
