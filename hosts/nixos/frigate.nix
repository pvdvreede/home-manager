{
  nixpkgs,
  inputs,
  ...
}: {
  frigate = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [../../nixos/frigate-configuration.nix];
    specialArgs.flake-inputs = inputs;
  };
}
