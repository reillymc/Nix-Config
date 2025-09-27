{
  lib,
  theme,
  ...
}:
{
  dconf.settings =
    if theme == "light" then
      {
        "org/gnome/desktop/interface" = {
          color-scheme = lib.mkDefault "prefer-light";
        };
      }
    else
      {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
}
