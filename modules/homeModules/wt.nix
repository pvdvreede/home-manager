{...}: {
  flake.homeModules.wt = {pkgs, ...}: {
    home.packages = [pkgs.wtp];
  };
}
