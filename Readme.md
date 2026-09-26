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

On hosts with a theme schedule, the theme switches automatically. To switch immediately, run `<hostname>-theme light` or `<hostname>-theme dark` (dark is the base system, light is a specialisation).

## Documentation

Custom options are documented within [NixOS Options](./docs/nixos-options.md) and [Home Options](./docs/home-options.md).
[NixOS Options](./docs/nixos-options.md) are configured in a host's `configuration.nix`. They define system-level configuration.
[Home Options](./docs/home-options.md) are configured in a host's `home.nix`/`<user>.nix` configuration. They define individual user configuration. They are not shared with the NixOS system configuration options (`mynixos`). When control is required across both domains, the configuration will be found in the NixOS system configuration and is passed into the home module.

### Generating docs

The following command can be used to update the docs with modified options `nix build .#docs && cp -rf result/* ./docs/ && rm result`.

## Secrets

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix). They are encrypted with a system key, usually located at `/etc/ssh/ssh_host_ed25519_key.pub` and a user/admin key, usually `~/.ssh/id_ed25519.pub`.

Edit a user secret from the [secrets](./secrets) folder with `agenix -e $HOSTNAME/{secret}.age`
Edit a system secret from the [secrets](./secrets) folder with `sudo EDITOR=nano agenix -e  $HOSTNAME/{secret}.age -i /etc/ssh/ssh_host_ed25519_key`

## Development

[statix](https://github.com/oppiliappan/statix) is used to lint the nix code in this project. Run with `nix run nixpkgs#statix check` or `nix run nixpkgs#statix fix`

When actively iterating, use `{hostname}-test` command to rebuild and activate without clogging up bootloader. Once ready, commit and run `{hostname}-rebuild`.`

## Tools

- [nix-ld](https://github.com/nix-community/nix-ld): Run unpatched dynamic binaries on NixOS, [Guide](https://blog.thalheim.io/2022/12/31/nix-ld-a-clean-solution-for-issues-with-pre-compiled-executables-on-nixos/).

- [vulnix](https://github.com/nix-community/vulnix): Vulnerability (CVE) scanner for Nix/NixOS.

## Tips

- Run a program from an older nixpkgs version with e.g. `nix run github:NixOS/nixpkgs/nixos-25.11#ghostty` or `nix shell github:NixOS/nixpkgs/nixos-25.11#ghostty`
- It is possible to build a VM from a host flake on the current or other machine for testing, e.g. `sudo nixos-rebuild build-vm --flake ./Projects/Nix-Config/#example`;
- Launch gnome settings from any DE `nix-shell -p gnome-control-center.out --run 'XDG_CURRENT_DESKTOP="gnome" gnome-control-center'`
- Check difference between persisted file system and current root: `sudo fd --one-file-system --base-directory / --type f --hidden --exclude "{tmp,etc/passwd}"`
