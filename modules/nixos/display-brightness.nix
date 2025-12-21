{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ddcutil
  ];

  services.udev.packages = [
    pkgs.ddcutil
  ];
}
