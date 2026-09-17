{
  config,
  lib,
  ...
}:
{
  options = {
    mynixos.steam.enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf config.mynixos.steam.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    mynixos.unfreePackages = [
      "steam"
      "steam-unwrapped"
    ];
  };
}
