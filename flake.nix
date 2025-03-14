{
  description = "Home Manager configuration of pvdvreede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {url = "github:numtide/flake-utils";};
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
    nur,
    nix-darwin,
    flake-utils,
    plasma-manager,
    nixos-wsl,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.nixfmt;
      packages.rye = pkgs.callPackage ./pkgs/rye.nix {};
      devShells.default =
        pkgs.mkShell {buildInputs = with pkgs; [nil nixfmt];};
    })
    // rec {
      homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./common.nix
          ./work.nix
          ./modules/shell
          ./modules/vscode
          ./modules/tmux.nix
          ./modules/helix.nix
          ./modules/lazygit.nix
          ./modules/wezterm
          ./modules/macappfix.nix
          ./modules/git.nix
          ./modules/vim.nix
          ./modules/tmux.nix
          ./modules/jujutsu.nix
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

      homeConfigurations.chromeos = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;

        modules = [
          ./common.nix
          ./modules/shell
          ./modules/zellij.nix
          ./modules/lazygit.nix
          ./modules/helix.nix
          ./modules/git.nix
          ./modules/vim.nix
          {
            home = {
              username = "pvdvreede";
              homeDirectory = "/home/pvdvreede";
              stateVersion = "23.11";
            };
          }
          {
            xdg.configFile."systemd/user/cros-garcon.service.d/override.conf".text = ''
              [Service]
              Environment="PATH=%h/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/usr/games:/sbin:/bin"
              Environment="XDG_DATA_DIRS=%h/.nix-profile/share:%h/.local/share:%h/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
            '';
          }
        ];
      };

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
          ./modules/helix.nix
          ./modules/firefox.nix
          ./modules/git.nix
          ./modules/vim.nix
          ./modules/tmux.nix
          ./modules/wezterm
          ./modules/yazi.nix
          ./modules/jujutsu.nix
          ./modules/qutebrowser.nix
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

      homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./common.nix
          ./modules/direnv.nix
          ./modules/shell
          ./modules/tmux.nix
          ./modules/lazygit.nix
          ./modules/helix.nix
          ./modules/git.nix
          ./modules/vim.nix
          # ./modules/glazewm
          ./modules/wezterm/wsl.nix
          {
            home = {
              username = "nixos";
              homeDirectory = "/home/nixos";
              stateVersion = "23.11";
            };
            programs.home-manager.enable = true;
          }
        ];
        extraSpecialArgs = {
          vscode-marketplace =
            nix-vscode-extensions.extensions.aarch64-darwin.vscode-marketplace;
        };
      };

      nixosConfigurations.vagabond = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./nixos/configuration.nix];
        specialArgs.flake-inputs = inputs;
      };

      nixosConfigurations.frigate = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./nixos/frigate-configuration.nix];
        specialArgs.flake-inputs = inputs;
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
          }
          ./wsl/configuration.nix
        ];
      };

      darwinConfigurations.work = nix-darwin.lib.darwinSystem {
        modules = [./nix-darwin/configuration.nix];
        specialArgs.flake-inputs = inputs;
      };
    };
}
