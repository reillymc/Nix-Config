{
  services.swaync = {
    enable = true;
    settings = {
      "timeout" = 10;
      "timeout-low" = 7;
      "timeout-critical" = 0;
      "control-center-margin-top" = 12;
      "control-center-margin-bottom" = 12;
      "control-center-margin-right" = 12;
      "widgets" = [
        "inhibitors"
        "dnd"
        "notifications"
        "mpris"
      ];
    };
  };
}
