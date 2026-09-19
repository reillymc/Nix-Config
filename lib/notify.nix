{
  lib,
  pkgs,
}:
let
  sanitizeName = lib.replaceStrings [ "@" ] [ "-" ];

  hooks = import ./systemd-hooks.nix { inherit lib; };
in
{
  inherit sanitizeName;

  mkNotifyCommand =
    {
      title,
      urgency,
      appName ? null,
    }:
    lib.concatStringsSep " " (
      [
        (lib.getExe' pkgs.libnotify "notify-send")
        "--urgency=${urgency}"
      ]
      ++ lib.optional (appName != null) "--app-name=${lib.escapeShellArg appName}"
      ++ [ (lib.escapeShellArg title) ]
    );

  mkHooks =
    {
      service,
      failure ? false,
      success ? false,
    }:
    hooks {
      prefix = "notify";
      name = sanitizeName service;
      inherit failure success;
    };
}
