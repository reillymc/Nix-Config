{
  age.secrets."opencode-go/api-key" = {
    file = ../../secrets/mist/opencode-go-api-key.age;
    path = "/home/dev/.config/opencode/api-key";
    owner = "dev";
    group = "dev";
    mode = "0400";
  };

  # agenix activation (runs as root) mkdir -p's these under ~/.config; the
  # dirs end up root-owned and block home-manager's user-level activation.
  # tmpfiles runs before home-manager-dev.service and (re)asserts ownership.
  systemd.tmpfiles.rules = [
    "d /home/dev 0700 dev dev -"
    "d /home/dev/.config 0755 dev dev -"
    "d /home/dev/.config/opencode 0755 dev dev -"
  ];
}
