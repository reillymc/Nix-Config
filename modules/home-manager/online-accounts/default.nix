{
  lib,
  mynixos,
  ...
}:
{
  config = lib.mkIf mynixos.online-accounts.enable {
    myhome.state.directories = [
      {
        directory = ".cache/evolution";
        backup.enable = false;
      }
      {
        directory = ".config/evolution";
        backup.enable = false;
      }
      {
        directory = ".config/goa-1.0";
        backup.enable = false;
      }
      {
        directory = ".local/share/evolution";
        backup.enable = false;
      }
      {
        directory = ".local/share/io.github.alainm23.planify";
        backup.enable = false;
      }
      {
        directory = ".local/share/keyrings";
        backup.enable = false;
      }
    ];
  };
}
