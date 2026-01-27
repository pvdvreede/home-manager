# dotfiles with Nix and Home Manager

To bootstrap, clone this repo and the following commands from below as needed.

## Nix Darwin

```
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run nix-darwin -- switch --flake .#work
```

## Home Manager

```
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run home-manager -- switch --flake .
```

## NixOS

```
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake .#nixos --option eval-cache false
```
