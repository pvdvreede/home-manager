{
  description = "Home Manager configuration of pvdvreede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = { url = "github:numtide/flake-utils"; };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, nix-vscode-extensions, nur, nix-darwin
    , flake-utils, plasma-manager, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        formatter = pkgs.nixfmt;
        devShells.default =
          pkgs.mkShell { buildInputs = with pkgs; [ nil nixfmt ]; };
      })

    // rec {
      homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./common.nix
          ./work.nix
          ./modules/shell
          ./modules/vscode
          ./modules/zellij.nix
          ./modules/helix.nix
          ./modules/lazygit.nix
          ./modules/kitty.nix
          ./modules/macappfix.nix
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
          plasma-manager.homeManagerModules.plasma-manager
          ./common.nix
          ./home.nix
          ./modules/shell
          ./modules/i3
          ./modules/vscode
          ./modules/zellij.nix
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

      darwinConfigurations.work = nix-darwin.lib.darwinSystem {
        modules = [ ./nix-darwin/configuration.nix ];
        specialArgs.flake-inputs = inputs;
      };
    };
}
