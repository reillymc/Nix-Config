{
  config,
  lib,
  pkgs,
  ...
}:
let
  stateLib = import ../../../lib/state.nix { inherit lib; };

  home = config.home.homeDirectory;

  entries = stateLib.mkStateEntries {
    state = config.myhome.state;
    resolve = e: "${home}/${stateLib.statePath e}";
  };

  extraExcludes = [
    "${home}/Projects/**/node_modules"
    "${home}/Projects/**/.expo"
    "${home}/Projects/**/.svelte-kit"
    "${home}/Projects/**/dist"
    "${home}/Projects/**/target"
    "${home}/Projects/**/logs"
  ];

  restoreScript = stateLib.mkRestoreScript {
    inherit pkgs entries;
    name = "${config.home.username}-restore";
    persistenceRoot = config.home.persistence.main.persistentStoragePath;
    user = true;
  };
in
{
  imports = [
    (stateLib.mkBackup {
      prefix = "myhome";
      inherit entries extraExcludes;
    })
  ];

  config = lib.mkIf config.myhome.state.backup.enable {
    services.restic.enable = true;

    systemd.user.services.restic-backups-daily = {
      Unit = {
        After = [ "agenix.service" ];
        Wants = [ "agenix.service" ];
      };
      Service = {
        PrivateTmp = true;
        TimeoutStartSec = "2h";
      };
    };

    home.packages = [ restoreScript ];
  };
}
