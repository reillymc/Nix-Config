{
  ...
}:
{
  services.gammastep = {
    enable = true;
    tray = true;
    latitude = 55.57; # TODO: make configurable
    longitude = 3.11;
    temperature = {
      day = 5500;
      night = 3200;
    };
  };
}
