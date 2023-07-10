{
  description = "Home Manager configuration of pvdvreede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    rec {
      homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./common.nix
          ./work.nix
          {
            home = {
              username = "paulv";
              homeDirectory = "/Users/paulv";
              stateVersion = "23.05";
            };
          }
        ];
      };

      homeConfigurations.paulv = homeConfigurations.work;

      homeConfigurations.home = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./common.nix
          {
            home = {
              username = "pvdvreede";
              homeDirectory = "/home/pvdvreede";
              stateVersion = "23.05";
            };
          }
        ];
      };
    };
}
