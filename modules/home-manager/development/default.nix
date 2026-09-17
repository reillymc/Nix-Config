{
  lib,
  config,
  ...
}:
{
  imports = [
    ./vscode.nix
    ./git.nix
    ./terminal.nix
    ./ssh-mist.nix
  ];

  config.myhome.state.directories = lib.mkIf config.programs.zed-editor.enable [
    {
      directory = ".config/zed";
      backup.enable = false;
    }
    {
      directory = ".local/share/zed";
      backup.enable = false;
    }
  ];
}
