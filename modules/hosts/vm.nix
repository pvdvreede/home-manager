{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.pveContainer
      self.nixosModules.nix
      self.nixosModules.fish
      self.nixosModules.vmMachine
    ];
  };

  flake.nixosModules.vmMachine = {pkgs, ...}: {
    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = [
      pkgs.wget
      pkgs.coreutils
    ];
  };
}
