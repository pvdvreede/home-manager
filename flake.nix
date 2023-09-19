{
  description = "Home Manager configuration of pvdvreede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-vscode-extensions, ... }:
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
              stateVersion = "23.11";
            };
          }
        ];
        extraSpecialArgs = {
          vscode-marketplace = nix-vscode-extensions.extensions.aarch64-darwin.vscode-marketplace;
        };
      };

      homeConfigurations.paulv = homeConfigurations.work;

      homeConfigurations.home = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./common.nix
          ./home.nix
          {
            home = {
              username = "pvdvreede";
              homeDirectory = "/home/pvdvreede";
              stateVersion = "23.11";
            };
          }
        ];
      };

      homeConfigurations.pvdvreede = homeConfigurations.home;
    };
}
