{...}: {
  flake.nixosModules.fish = {pkgs, ...}: {
    programs.fish = {
      enable = true;
    };

    environment.shells = [pkgs.fish];

    users.defaultUserShell = pkgs.fish;
  };
}
