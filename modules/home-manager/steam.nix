{
  config,
  lib,
  ...
}:
let
  cfg = config.myhome.steam;
in
{
  options.myhome.steam.enable = lib.mkEnableOption "Steam state persistence and backups";

  config = lib.mkIf cfg.enable {
    myhome.state.directories = [
      {
        directory = ".local/share/Steam";
        backup.enable = false;
      }
      # The steamapps tree is persisted as part of `.local/share/Steam' above;
      # this entry selects the Proton prefixes for backup (rather than the
      # whole Steam library). The disposable Windows system tree is excluded.
      {
        directory = ".local/share/Steam/steamapps/compatdata";
        backup.exclude = [
          "*/pfx/drive_c/windows"
          "*/pfx/drive_c/ProgramData"
        ];
      }
      {
        directory = ".steam";
        backup.enable = false;
      }
    ];
  };
}
