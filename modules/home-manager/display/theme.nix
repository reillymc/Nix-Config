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

  systemd.user.services.switchToSystemDarkMode = {
    Unit.Description = "Switch to system dark mode configuration";
    Unit.After = [ "graphical-session.target" ];
    Service = {
      ExecStart = "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl start switchToSystemDarkMode.service";
      Type = "oneshot";
    };
  };

  systemd.user.services.switchToSystemLightMode = {
    Unit.Description = "Switch to system light mode configuration";
    Unit.After = [ "graphical-session.target" ];
    Service = {
      ExecStart = "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl start switchToSystemLightMode.service";
      Type = "oneshot";
    };
  };
}
