{
  lib,
  pkgs,
  config,
  mynixos,
  ...
}:
let

  themeLib = import ../../../../lib/theme.nix { inherit lib; };
  palette = config.myhome.display.palette;

  popupCases = lib.concatMapStringsSep "\n" (title: ''
    ${lib.escapeShellArg title})
      popupify "$address"
      ;;
  '') config.myhome.display.popupify.titles;

  hyprland-popupify-handler = pkgs.writeShellScriptBin "hyprland-popupify-handler" ''
    set -euo pipefail

    popupify() {
      local address="$1"

      local monitorHeight
      monitorHeight=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .height')

      local usableHeight
      usableHeight=$((monitorHeight - ${toString palette.layout.reservedYSpace}))

      local targetHeight
      targetHeight=$((usableHeight * ${toString (themeLib.toPercentInt palette.size.height.regular)} / 100))

      hyprctl --batch "\
        dispatch setfloating address:0x$address; \
        dispatch resizewindowpixel exact ${toString palette.size.width.regular} $targetHeight, address:0x$address; \
        dispatch centerwindow; \
      "
    }

    windowtitlev2() {
      IFS=',' read -r -a args <<< "$1"

      local address="''${args[0]#*>>}"
      local title="''${args[1]}"

      case "$title" in
        ${popupCases}
      esac
    }

    handle() {
      case "$1" in
        windowtitlev2\>*)
          windowtitlev2 "$1"
          ;;
      esac
    }

    SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

    echo "Connecting to: $SOCKET"

    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$SOCKET" |
      while read -r line; do
        handle "$line"
      done
  '';
in
{
  systemd.user.services.hyprland-popupify-handler = lib.mkIf mynixos.hyprland.enable {
    Unit = {
      Description = "Hyprland Popupify Window Handler";

      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${hyprland-popupify-handler}/bin/hyprland-popupify-handler";

      Restart = "always";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
