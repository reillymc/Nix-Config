# Dotfiles

My NixOS system configurations

## Rebuilding

`sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#terra`

or alternatively, rebuild directly into light mode
`sudo nixos-rebuild switch --flake ~/Projects/Nix-Config/#terra --specialisation light`

## Switch themes

`sudo systemctl start switchToLightMode.service`
`sudo systemctl start switchToDarkMode.service`
