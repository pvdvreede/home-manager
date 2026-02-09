{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.eza];

  programs.fish.shellAliases.ll = lib.mkForce "eza -la --icons=auto";
}
