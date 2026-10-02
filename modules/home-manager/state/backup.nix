{
  lib,
  config,
  ...
}:
let
  stateLib = import ../../../lib/state.nix { inherit lib; };

  home = config.home.homeDirectory;
in
{
  imports = [
    (stateLib.mkBackup {
      prefix = "myhome";
      inherit home;
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
  };
}
