{...}: {
  flake.homeModules.nix = {pkgs, ...}: {
    home.packages = with pkgs; [
      nixd
      alejandra
    ];

    nix.settings = {
      extra-experimental-features = "nix-command flakes";
    };
    nix.gc = {
      automatic = true;
    };
  };
}
