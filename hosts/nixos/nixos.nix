{
  nixpkgs,
  nixos-wsl,
  ...
}: {
  nixos = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      nixos-wsl.nixosModules.default
      {
        system.stateVersion = "24.05";
        wsl.enable = true;
      }
      ../../wsl/configuration.nix
    ];
  };
}
