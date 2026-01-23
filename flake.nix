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
    nu-scripts = {
      flake = false;
      url = "github:nushell/nu_scripts";
    };
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
    nu-scripts,
    ...
  } @ inputs: let
    # Helper to get pkgs for a specific system
    pkgsForSystem = system: nixpkgs.legacyPackages.${system};

    # Generate checks for home-manager configurations
    homeChecks =
      nixpkgs.lib.mapAttrs' (name: config: {
        name = "home-manager-${name}";
        value = config.activationPackage;
      })
      inputs.self.homeConfigurations;

    # Generate checks for NixOS configurations
    nixosChecks =
      nixpkgs.lib.mapAttrs' (name: config: {
        name = "nixos-${name}";
        value = config.config.system.build.toplevel;
      })
      inputs.self.nixosConfigurations;

    # Generate checks for nix-darwin configurations
    darwinChecks =
      nixpkgs.lib.mapAttrs' (name: config: {
        name = "darwin-${name}";
        value = config.config.system.build.toplevel;
      })
      inputs.self.darwinConfigurations;
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = pkgsForSystem system;
    in {
      formatter = pkgs.nixfmt;
      packages.rye = pkgs.callPackage ./pkgs/rye.nix {};
      packages.vibekanban = pkgs.callPackage ./pkgs/vibekanban.nix {};
      devShells.default =
        pkgs.mkShell {buildInputs = with pkgs; [nil nixfmt];};
    })
    // rec {
      inherit (inputs) self; # Needed to reference self.homeConfigurations etc.

      # Import all home-manager configurations
      homeConfigurations =
        (import ./hosts/home-manager/work.nix {
          inherit inputs home-manager nixpkgs nix-vscode-extensions nu-scripts;
        })
        // (import ./hosts/home-manager/chromeos.nix {
          inherit home-manager nixpkgs;
        })
        // (import ./hosts/home-manager/home.nix {
          inherit inputs home-manager nixpkgs nix-vscode-extensions nu-scripts plasma-manager;
        })
        // (import ./hosts/home-manager/wsl.nix {
          inherit inputs home-manager nixpkgs nix-vscode-extensions nu-scripts;
        });

      # Import all NixOS configurations
      nixosConfigurations =
        (import ./hosts/nixos/vagabond.nix {inherit nixpkgs inputs;})
        // (import ./hosts/nixos/frigate.nix {inherit nixpkgs inputs;})
        // (import ./hosts/nixos/nixos.nix {inherit nixpkgs nixos-wsl;});

      # Import all Darwin configurations
      darwinConfigurations = import ./hosts/darwin/work.nix {inherit nix-darwin inputs;};

      checks = homeChecks // nixosChecks // darwinChecks;
    };
}
