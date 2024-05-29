{ pkgs, lib, home-manager, ... }@inputs:

{
  nixosConfigurations.vagabond = lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ../modules/lightdm.nix
      ../modules/kde.nix

      home-manager.nixosModules.home-manager
      {
        home = {
          username = "pvdvreede";
          homeDirectory = "/home/pvdvreede";
          stateVersion = "23.11";
        };
      }
      ../modules/alacritty.nix
      ../modules/plasma.nix
      ../modules/helix.nix
      ../modules/shell
    ];
    specialArgs.flake-inputs = inputs;
  };
}
