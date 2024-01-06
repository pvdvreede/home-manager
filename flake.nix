{
  description = "Home Manager configuration of pvdvreede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, nix-vscode-extensions, nur, ... }@inputs: rec {

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;

      homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./common.nix
          ./work.nix
          ./modules/vscode
          ./modules/lazygit.nix
          ./modules/alacritty.nix
          {
            home = {
              username = "paulv";
              homeDirectory = "/Users/paulv";
              stateVersion = "23.11";
            };
          }
        ];
        extraSpecialArgs = {
          vscode-marketplace =
            nix-vscode-extensions.extensions.aarch64-darwin.vscode-marketplace;
        };
      };

      homeConfigurations.paulv = homeConfigurations.work;

      homeConfigurations.home = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./common.nix
          ./home.nix
          ./modules/gnome.nix
          ./modules/vscode
          ./modules/lazygit.nix
          ./modules/alacritty.nix
          ./modules/helix.nix
          {
            home = {
              username = "pvdvreede";
              homeDirectory = "/home/pvdvreede";
              stateVersion = "23.11";
            };
          }
        ];
        extraSpecialArgs = {
          vscode-marketplace =
            nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace;
        };
      };

      homeConfigurations.pvdvreede = homeConfigurations.home;

      nixosConfigurations.vagabond = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/configuration.nix ];
        specialArgs.flake-inputs = inputs;
      };
    };
}
