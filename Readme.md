# NixOS System Configuration

My NixOS system configurations. The project is broken up into `hosts` and modules. Hosts are a config set for each individual machine, while modules are reusable nix modules that are then composed into a machine config in hosts.

## Rebuilding

`sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#example`

or alternatively, rebuild directly into light mode
`sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#example --specialisation light`

Once the system is setup, the command `rebuild-switch` is added to the path for convenience. This handles rebuilding with the correct host specialisation.

## Upgrading

To upgrade dependency versions (`flake.lock`) file, run `nix flake update`.

## Switch themes

`sudo systemctl start switchToSystemLightMode.service`

`sudo systemctl start switchToSystemDarkMode.service`

## Documentation

Custom options are documented within [NixOS Options](./docs/nixos-options.md) and [Home Options](./docs/home-options.md).
[NixOS Options](./docs/nixos-options.md) are configured in a host's `configuration.nix`. They define system-level configuration.
[Home Options](./docs/home-options.md) are configured in a host's `home.nix`/`<user>.nix` configuration. They define individual user configuration. They are not shared with the NixOS system configuration options (`mynixos`). When control is required across both domains, the configuration will be found in the NixOS system configuration and is passed into the home module.

### Generating docs

The following command can be used to update the docs with modified options `nix build .#docs && cp -rf result/* ./docs/ && rm result`.

## Secrets

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix). They are encrypted with a system key, usually located at `/etc/ssh/ssh_host_ed25519_key.pub` and a user/admin key, usually `~/.ssh/id_ed25519.pub`.

Edit a secret from the [secrets](./secrets) folder with `nix run github:ryantm/agenix -- -e $HOSTNAME/{secret}.age`

## Development

[statix](https://github.com/oppiliappan/statix) is used to lint the nix code in this project. Run with `nix run nixpkgs#statix check` or `nix run nixpkgs#statix fix`

## Tools

- [nix-ld](https://github.com/nix-community/nix-ld): Run unpatched dynamic binaries on NixOS, [Guide](https://blog.thalheim.io/2022/12/31/nix-ld-a-clean-solution-for-issues-with-pre-compiled-executables-on-nixos/).

## Tips

- Run a program from an older nixpkgs version with e.g. `nix run github:NixOS/nixpkgs/nixos-25.11#ghostty` or `nix shell github:NixOS/nixpkgs/nixos-25.11#ghostty`
