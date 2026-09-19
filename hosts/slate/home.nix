{
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.agenix.homeManagerModules.default
    ../../modules/home-manager
    ../../users/reilly.nix
  ];

  myhome.display = {
    monitors = [
      {
        output = "eDP-1";
        model = "LQ135P1JX51";
        resolution = "2256x1504";
        refreshRate = 60;
        position = "0x0";
        scale = 1.0;
        bitdepth = 10;
        control = "brightnessctl";
      }
      {
        output = "DP-1";
        model = "eiq-495KCSUW";
        resolution = "5120x1440";
        refreshRate = 144;
        position = "2256x0";
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
    "alsa_output.pci-0000_00_1f.3.hdmi-stereo" # Speaker via monitor
  ];

  age = {
    secretsDir = "${config.home.homeDirectory}/.local/share/agenix";
    secrets = {
      "restic-backup/env".file = ../../secrets/slate/reilly/restic-backup/env.age;
      "restic-backup/password".file = ../../secrets/slate/reilly/restic-backup/password.age;
      "restic-backup/repo".file = ../../secrets/slate/reilly/restic-backup/repo.age;
    };
  };

  myhome.healthchecks.checks = [ "restic-backups-daily" ];

  myhome.notify = {
    enable = true;
    services = [
      {
        service = "restic-backups-daily";
        failure = {
          title = "Backup failed";
          appName = "restic";
        };
        success = {
          title = "Backup complete";
          appName = "restic";
        };
      }
    ];
  };
  myhome.state = {
    backup = {
      enable = true;
      settings = {
        repositoryFile = config.age.secrets."restic-backup/repo".path;
        passwordFile = config.age.secrets."restic-backup/password".path;
        environmentFile = config.age.secrets."restic-backup/env".path;
      };
    };
    directories = [
      {
        directory = ".config/git/credentials";
        backup.enable = false;
      }
      {
        directory = ".expo";
        backup.enable = false;
      }
    ];
    files = [
      {
        file = ".npmrc";
        backup.enable = false;
      }
    ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
