{
  lib,
  config,
  ...
}:
{
  options = {
    myhome.obsidian.enable = lib.mkEnableOption "enables obsidian";
  };

  config = lib.mkIf config.myhome.obsidian.enable {
    myhome.myUnfreePackages = [ "obsidian" ];

    programs.obsidian = {
      enable = true;
    };
  };
}
