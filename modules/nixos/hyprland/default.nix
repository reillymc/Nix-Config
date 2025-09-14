{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    # TODO: control this with same variable as home manager hyprland
    mynixos.hyprland.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.mynixos.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      kitty
    ];
  };
}
