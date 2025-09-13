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
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "vscode"
        "vscode-extension-ms-vscode-remote-remote-containers"
      ];

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-containers
        jnoortheen.nix-ide
      ];
    };

    home.packages = [ pkgs.nixfmt-rfc-style ];
  };
}
