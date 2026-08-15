{
  lib,
  pkgs,
  ...
}:

{
  options.microvm = {
    extraZshInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines to add to zsh initContent";
    };
  };

  config = {
    home.username = "dev";
    home.homeDirectory = "/home/dev";

    programs.zsh = {
      enable = true;
      history = {
        size = 4000;
        save = 10000000;
        ignoreDups = true;
        share = false;
        append = true;
      };
      initContent = ''
        source ${pkgs.ghostty.shell_integration}/zsh/ghostty-integration
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      '';
    };

    programs.starship = {
      enable = true;
      settings = {
        format = "$username$directory$git_branch$git_status$status$cmd_duration$jobs$time$character";
      };
    };

    home.stateVersion = "26.05";

    programs.home-manager.enable = true;

    programs.opencode = {
      enable = true;
      settings = {
        "autoupdate" = false;
        provider."opencode-go".options.apiKey = "{file:/run/agenix/opencode-go/api-key}";
      };
    };

    home.persistence."/var/persist" = {
      hideMounts = true;
      directories = [
        ".local/share/opencode"
        ".local/state/opencode"
        ".vscode-server"
      ];
      files = [
        ".zsh_history"
      ];
    };
  };
}
