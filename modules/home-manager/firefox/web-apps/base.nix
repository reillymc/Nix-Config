{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Stable 32-bit numeric ID derived from the profile name to avoid manually tracking profile IDs
  mkProfileId =
    name:
    let
      hex = builtins.hashString "sha1" name;
      shortHex = builtins.substring 0 8 hex;
      id = lib.fromHexString shortHex; # Convert hex to decimal
    in
    id;

  webAppIcons = pkgs.stdenv.mkDerivation {
    name = "webapp-icons";
    src = ./icons;
    installPhase = ''
      mkdir -p $out/share/icons/webapps
      cp -r * $out/share/icons/webapps/
    '';
  };

  mkWebAppEntry = app: {
    inherit (app) name;
    type = "Application";
    exec = "${pkgs.firefox}/bin/firefox -no-remote --profile \"${config.xdg.configHome}/mozilla/firefox/${app.id}\" --class \"${app.id}\" --name \"${app.name}\" --new-window \"${app.url}\"";
    icon = "${webAppIcons}/share/icons/webapps/${app.icon}";
    categories = [ "X-Internet" ];
    settings = {
      Keywords = "WebApp";
      StartupWMClass = app.id;
    };
  };
in
{
  inherit
    mkWebAppEntry
    mkProfileId
    ;
}
