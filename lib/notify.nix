{
  lib,
  pkgs,
}:
rec {
  sanitizeName = lib.replaceStrings [ "@" ] [ "-" ];

  mkNotifyCommand =
    {
      title,
      body ? null,
      urgency ? "normal",
      appName ? null,
      icon ? null,
      notifySend ? pkgs.libnotify,
    }:
    lib.concatStringsSep " " (
      [ (lib.getExe' notifySend "notify-send") ]
      ++ lib.optional (appName != null) "--app-name=${lib.escapeShellArg appName}"
      ++ [ "--urgency=${urgency}" ]
      ++ lib.optional (icon != null) "--icon=${lib.escapeShellArg icon}"
      ++ [ (lib.escapeShellArg title) ]
      ++ lib.optional (body != null) (lib.escapeShellArg body)
    );

  mkHooks =
    {
      service,
      failure ? null,
      success ? null,
    }:
    let
      name = sanitizeName service;
    in
    {
      OnFailure = lib.optional (failure != null) "notify-${name}-failure.service";
      OnSuccess = lib.optional (success != null) "notify-${name}-success.service";
    };
}
