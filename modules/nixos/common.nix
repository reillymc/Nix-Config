{
  hostname,
  inputs,
  ...
}:
{
  networking.hostName = hostname;

  hardware.enableRedistributableFirmware = true;
  systemd.network.wait-online.enable = false;
  time.timeZone = "Europe/London";
  users.mutableUsers = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  i18n.inputMethod.enable = false;

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  # Prevent heavy nix builds starving desktop/user resources,
  # keeping the system usable.
  systemd.services.nix-daemon.serviceConfig = {
    Nice = 10;
    IOWeight = 20;
  };
}
