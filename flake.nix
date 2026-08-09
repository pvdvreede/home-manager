{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-wsl.url = "github:nix-community/nixos-wsl/release-25.11";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    herdr.url = "github:ogulcancelik/herdr";
    herdr.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    }
    ({
      config,
      lib,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      # Define your systems list here at the top level of the mkFlake configuration
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      # Import your modules using import-tree
      imports = [
        # Example of loading all flake-parts modules from a directory tree
        (inputs.import-tree ./modules)
        # You can add more imports here
        inputs.home-manager.flakeModules.home-manager
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        flakeUrl = "github:pvdvreede/home-manager";

        runtimeInputs = [
          inputs.home-manager.packages.${system}.default
        ]
        ++ lib.optional (pkgs.stdenv.hostPlatform.isDarwin)
          inputs.nix-darwin.packages.${system}.default;

        mkInstallApp = {
          host,
          tool,
        }: let
          script = pkgs.writeShellApplication {
            name = "install-${host}";
            inherit runtimeInputs;
            text = ''
              set -euo pipefail
              flake_url="''${DOTFILES_FLAKE_URL:-${flakeUrl}}"
              exec ${tool} switch --flake "$flake_url#${host}" "$@"
            '';
          };
        in {
          type = "app";
          program = "${script}/bin/install-${host}";
        };

        defaultScript = pkgs.writeShellApplication {
          name = "install-default";
          inherit runtimeInputs;
          text = ''
            set -euo pipefail
            flake_url="''${DOTFILES_FLAKE_URL:-${flakeUrl}}"
            host="$(hostname | tr '[:upper:]' '[:lower:]')"
            case "$host" in
              pauls-mbp* | macbook*)
                exec darwin-rebuild switch --flake "$flake_url#macbook" "$@"
                ;;
              desktop*)
                exec home-manager switch --flake "$flake_url#desktop" "$@"
                ;;
              vm*)
                exec home-manager switch --flake "$flake_url#vm" "$@"
                ;;
              *)
                echo "Unknown host: $host" >&2
                echo "Known hosts: macbook, desktop, vm" >&2
                exit 1
                ;;
            esac
          '';
        };
      in {
        apps = {
          default = {
            type = "app";
            program = "${defaultScript}/bin/install-default";
          };
          macbook = mkInstallApp {
            host = "macbook";
            tool = "darwin-rebuild";
          };
          desktop = mkInstallApp {
            host = "desktop";
            tool = "home-manager";
          };
          vm = mkInstallApp {
            host = "vm";
            tool = "home-manager";
          };
        };
      };
    });
}
