{
  ...
}:
{
  imports = [
    ../../../modules/home-manager
    ./common.nix

  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "guest";
  home.homeDirectory = "/home/guest";

  myhome.web-apps = {
    enable = true;
    apps.jellyfin.enable = true;
    apps.seerr.enable = true;
    apps.youtube.enable = true;
  };

  myhome.state = {
    persist.hideMounts = true;
    directories = [
      {
        directory = "Desktop";
        backup.enable = false;
      }
      "Documents"
      {
        directory = "Downloads";
        backup.enable = false;
      }
      "Music"
      "Pictures"
      {
        directory = "Public";
        backup.enable = false;
      }
      "Videos"
    ];
    files = [
      {
        file = ".bash_history";
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
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
