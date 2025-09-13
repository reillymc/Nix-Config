{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    myhome.vscode.enable = lib.mkEnableOption "enables vscode";
  };

  config = lib.mkIf config.myhome.vscode.enable {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-containers
        jnoortheen.nix-ide
      ];
    };

    environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
  };
}
