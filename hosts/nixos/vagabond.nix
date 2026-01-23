{
  nixpkgs,
  inputs,
  ...
}: {
  vagabond = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [../../nixos/configuration.nix];
    specialArgs.flake-inputs = inputs;
  };
}
