{ config, pkgs, webAppIcons }:
{
  mkWebAppEntry =
    app:
    let
      pkg = app.package or pkgs.firefox;
    in
    {
      inherit (app) name;
      type = "Application";
      exec = "${pkg}/bin/firefox -no-remote --profile \"${config.xdg.configHome}/mozilla/firefox/${app.id}\" --class \"${app.id}\" --name \"${app.name}\" --new-window \"${app.url}\"";
      icon = "${webAppIcons}/share/icons/webapps/${app.icon}";
      categories = [ "X-Internet" ];
      settings = {
        Keywords = "WebApp";
        StartupWMClass = app.id;
      };
    };
}
