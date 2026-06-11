{
  config,
  pkgs,
  ...
}:
let
  mode = config.myhome.display.theme.mode;
  themeName = if mode == "light" then "Adwaita" else "Adwaita-dark";
  colorScheme = if mode == "light" then "prefer-light" else "prefer-dark";
in
{
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
}
