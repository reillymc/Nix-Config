{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.myhome.ssh-devvm.enable = lib.mkEnableOption "SSH agent forwarding + confirmation for the devvm";

  config = lib.mkIf config.myhome.ssh-devvm.enable {
    programs.ssh = {
      enable = lib.mkDefault true;

      settings.devvm = {
        hostname = "192.168.83.6";
        user = "dev";
        forwardAgent = true;
        identityAgent = "~/.ssh/devvm-agent.sock";
      };
    };

    # Dedicated confirmation agent used for the devvm connection
    systemd.user.services.ssh-agent-devvm = {
      Unit.Description = "SSH agent for devvm (confirmation mode)";

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f %h/.ssh/devvm-agent.sock";
        ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %h/.ssh/devvm-agent.sock";
        # Load the GitHub key with confirmation so every use prompts on host.
        ExecStartPost = pkgs.writeShellScript "ssh-add-devvm" ''
          export SSH_AUTH_SOCK="$HOME/.ssh/devvm-agent.sock"
          exec ${pkgs.openssh}/bin/ssh-add -c "$HOME/.ssh/github"
        '';
        Environment = [
          "SSH_ASKPASS=${pkgs.openssh-askpass}/libexec/gtk-ssh-askpass"
          "WAYLAND_DISPLAY=wayland-1"
          "GDK_BACKEND=wayland"
        ];
        Restart = "on-failure";
        RestartSec = "200ms";
        SuccessExitStatus = "0 2";
      };

      Install.WantedBy = [ "default.target" ];
    };

    home.packages = [ pkgs.openssh-askpass ];
  };
}
