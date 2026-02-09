{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ../../pkgs/aerospace.nix {})
  ];

  home.file = {
    aeroconfig = {
      source = ./aerospace.toml;
      target = ".aerospace.toml";
    };
  };
}
