{
  config,
  lib,
  ...
}:
{
  options = {
    mynixos.steam.enable = lib.mkEnableOption "enables steam";
  };

  config = lib.mkIf config.mynixos.steam.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    mynixos.myUnfreePackages = [
      "steam"
      "steam-unwrapped"
    ];
  };
}
