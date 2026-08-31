{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.myhome.ssh-mist.enable = lib.mkEnableOption "SSH agent forwarding + confirmation for the mist";

  config = lib.mkIf config.myhome.ssh-mist.enable {
    programs.ssh = {
      enable = lib.mkDefault true;

      settings.mist = {
        hostname = "192.168.83.6";
        user = "dev";
        forwardAgent = true;
        identityAgent = "~/.ssh/mist-agent.sock";
      };
    };

    # Dedicated confirmation agent used for the mist connection
    systemd.user.services.ssh-agent-mist = {
      Unit.Description = "SSH agent for mist (confirmation mode)";

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f %h/.ssh/mist-agent.sock";
        ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %h/.ssh/mist-agent.sock";
        # Load the GitHub key with confirmation so every use prompts on host.
        # Retry briefly since the agent's socket may not be ready yet
        ExecStartPost = pkgs.writeShellScript "ssh-add-mist" ''
          export SSH_AUTH_SOCK="$HOME/.ssh/mist-agent.sock"
          for _ in {1..10}; do
            ${pkgs.openssh}/bin/ssh-add -c "$HOME/.ssh/github" && exit 0
            ${pkgs.coreutils}/bin/sleep 0.5
          done
          exit 1
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
