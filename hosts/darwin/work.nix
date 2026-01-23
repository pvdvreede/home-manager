{
  nix-darwin,
  inputs,
  ...
}: {
  work = nix-darwin.lib.darwinSystem {
    modules = [../../nix-darwin/configuration.nix];
    specialArgs.flake-inputs = inputs;
  };
}
