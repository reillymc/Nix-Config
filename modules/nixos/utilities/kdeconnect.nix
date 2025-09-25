{
  pkgs,
  ...
}:
{
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde # required to provide kdeconnctd which is started with hyprland
  ];
}
