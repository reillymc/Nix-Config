{
  config,
  lib,
  pkgs,
  ...
}:
let
  stateLib = import ../../../lib/state.nix { inherit lib; };

  entries = stateLib.mkStateEntries {
    state = config.mynixos.state;
  };

  restoreScript = stateLib.mkRestoreScript {
    inherit pkgs entries;
    name = "${config.networking.hostName}-restore";
    persistenceRoot = config.environment.persistence.main.persistentStoragePath;
    user = false;
  };
in
{
  imports = [
    (stateLib.mkBackup {
      prefix = "mynixos";
      inherit entries;
    })
  ];

  config = lib.mkIf config.mynixos.state.backup.enable {
    environment.systemPackages = [ restoreScript ];
  };
}
