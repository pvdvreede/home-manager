{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-wsl.url = "github:nix-community/nixos-wsl/release-25.11";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    }
    ({
      config,
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
    });
}
