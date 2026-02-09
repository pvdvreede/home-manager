{inputs, ...}: {
  flake.nixosModules.wsl = {pkgs, ...}: {
    programs.nix-ld = {
      enable = true;
    };

    system.stateVersion = "25.11";
    wsl.enable = true;

    boot.binfmt.emulatedSystems = ["aarch64-linux"];

    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];
  };
}
