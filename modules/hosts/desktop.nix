{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.wsl
      self.nixosModules.nix
      self.nixosModules.i3-rdp
      self.nixosModules.fish
      self.nixosModules.desktopMachine
    ];
  };

  flake.nixosModules.desktopMachine = {pkgs, ...}: {
    virtualisation.docker = {
      enable = true;
    };

    nixpkgs.hostPlatform = "x86_64-linux";

    users.users.nixos = {
      isNormalUser = true;
      hashedPassword = "$6$hepjXE61HxWzfEbl$NF.ujvhEopLv8Ce54mfVuS44g3iUdJ9pD7iUBqOuIPYAjQJ8diQSaqkorNC.ZUJPTdkU0.C9uIG1c/tv.j9qt1";
      extraGroups = [
        "wheel"
        "docker"
      ];
    };

    environment.systemPackages = [
      pkgs.wget
      pkgs.coreutils
    ];
  };

  flake.homeConfigurations.desktop = {pkgs, ...}: {
    modules = [
      self.homeModules.i3
    ];
  };
}
