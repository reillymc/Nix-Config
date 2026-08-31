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

  config.myhome.persistence.directories = lib.mkIf config.programs.zed-editor.enable [
    ".config/zed"
    ".local/share/zed"
  ];
}
