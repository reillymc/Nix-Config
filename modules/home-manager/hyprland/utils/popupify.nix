{
  lib,
  pkgs,
  config,
  ...
}:
let

  themeLib = import ../../../../lib/theme.nix { inherit lib; };
  theme = config.myhome.display.theme;

  popupCases = lib.concatMapStringsSep "\n" (title: ''
    ${lib.escapeShellArg title})
      popupify "$address"
      ;;
  '') config.myhome.display.popupify.titles;

  hyprland-popupify-handler = pkgs.writeShellScriptBin "hyprland-popupify-handler" ''
    set -euo pipefail

    popupify() {
      local address="$1"

      monitorHeight=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .height')
      targetHeight=$((monitorHeight * ${toString (themeLib.toPercentInt theme.size.popup.regular.height)} / 100))
      targetWidth=$((monitorHeight * ${toString (themeLib.toPercentInt theme.size.popup.regular.width)} / 100))

      hyprctl --batch "\
        dispatch setfloating address:0x$address; \
        dispatch resizewindowpixel exact $targetWidth $targetHeight, address:0x$address; \
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
  home.packages = [
    hyprland-popupify-handler
  ];
}
