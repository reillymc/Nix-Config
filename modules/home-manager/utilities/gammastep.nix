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
      day = 6500;
      night = 3200;
    };
    settings = {
      general = {
        elevation-high = -9;
        elevation-low = -15;
      };
    };
  };
}
