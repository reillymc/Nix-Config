{ pkgs }:
{
  webAppIcons = pkgs.stdenv.mkDerivation {
    name = "webapp-icons";
    src = ../icons;
    installPhase = ''
      mkdir -p $out/share/icons/webapps
      cp -r * $out/share/icons/webapps/
    '';
  };
}
