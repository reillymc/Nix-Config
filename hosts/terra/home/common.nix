{
  # Ensure Hyprland prefers the discrete GPU (amd-dGPU) but includes the
  # integrated GPU (amd-iGPU) as a fallback. These refer to the stable udev
  # symlinks we create in the system configuration.
  # The opposite is also available, commented out - however hyprland on
  # 5k ultrawide seems to suffer from poor performance when using the iGPU
  wayland.windowManager.hyprland.settings = {
    env = [
      "AQ_DRM_DEVICES,/dev/dri/amd-dgpu:/dev/dri/amd-igpu"
      # "AQ_DRM_DEVICES,/dev/dri/amd-igpu:/dev/dri/amd-dgpu"
    ];
  };

  xdg.userDirs = {
    setSessionVariables = true;
    enable = true;
    createDirectories = true;
  };

  myhome.display = {
    monitors = [
      {
        output = "DP-3";
        model = "eiq-495KCSUW";
        resolution = "5120x1440";
        refreshRate = 120;
        position = "0x0";
        scale = 1.0;
        bitdepth = 10;
        isUltrawide = true;
        control = "ddcutil";
      }
    ];
    brightness = {
      maxTime = "07:00";
      minTime = "22:45";
    };
    nightShift = {
      clearTime = "07:00";
      shiftTime = "21:30";
    };
  };

  myhome.audio.devices = [
    "bluez_output.94_DB_56_D5_A1_18.1" # Bluetooth Headphones
    "alsa_output.pci-0000_0e_00.1.hdmi-stereo" # Speaker via monitor
  ];

}
