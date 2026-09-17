{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.agenix.homeManagerModules.default
    ../../../modules/home-manager
    ../../../users/reilly.nix
    ./common.nix
  ];

  myhome.ssh-mist.enable = true;

  programs.ssh.settings.slate = {
    IdentityFile = "~/.ssh/slate";
    User = "reilly";
    HostName = "slate";
  };

  home.packages = with pkgs; [
    libreoffice
    prismlauncher
    gocryptfs
  ];

  age = {
    secretsDir = "${config.home.homeDirectory}/.local/share/agenix";
    secrets = {
      "restic-backup/env".file = ../../../secrets/terra/reilly/restic-backup/env.age;
      "restic-backup/password".file = ../../../secrets/terra/reilly/restic-backup/password.age;
      "restic-backup/repo".file = ../../../secrets/terra/reilly/restic-backup/repo.age;
    };
  };

  myhome.state = {
    backup = {
      enable = true;
      settings = {
        repositoryFile = config.age.secrets."restic-backup/repo".path;
        passwordFile = config.age.secrets."restic-backup/password".path;
        environmentFile = config.age.secrets."restic-backup/env".path;
      };
      notify = {
        startUrl = "https://healthchecks.homelab.reillymc.com/ping/062aac27-12cb-4d9c-944d-8f64357f76e2/start";
        successUrl = "https://healthchecks.homelab.reillymc.com/ping/062aac27-12cb-4d9c-944d-8f64357f76e2";
        failureUrl = "https://healthchecks.homelab.reillymc.com/ping/062aac27-12cb-4d9c-944d-8f64357f76e2/fail";
      };
    };
    directories = [
      {
        directory = ".config/bruno";
        backup.enable = false;
      }
      {
        directory = ".local/share/io.github.CyberTimon.RapidRAW";
        backup.enable = false;
      }
      {
        directory = ".local/share/PrismLauncher";
        backup.enable = false;
      }
      ".local/share/Terraria"
    ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
