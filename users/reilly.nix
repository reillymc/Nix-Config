{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "reilly";
  home.homeDirectory = "/home/reilly";

  programs.git = {
    settings = {
      user = {
        name = "reillymc";
        email = "dev@reillymc.com";
      };
      core = {
        editor = "code --wait"; # Todo: make configurable
      };
      credential = {
        helper = "libsecret";
      };
      help = {
        autocorrect = "prompt";
      };
    };
  };

}
