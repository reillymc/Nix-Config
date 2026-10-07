{
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "reillymc";
        email = "dev@reillymc.com";
      };
      help = {
        autocorrect = "prompt";
      };
      push.autoSetupRemote = true;
    };
  };

  home.packages = [ pkgs.git ];
}
