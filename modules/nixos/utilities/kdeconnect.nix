{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mynixos.kdeconnect.enable = lib.mkEnableOption "KDE Connect";

  config = lib.mkIf config.mynixos.kdeconnect.enable {
    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.kdeconnect-kde # required to provide kdeconnctd which is started with hyprland
    ];
  };
}
