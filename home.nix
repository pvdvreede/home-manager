{ pkgs, ... }:

{
  home.sessionVariables = { EDITOR = "hx"; };

  programs.fish.shellAliases = { vim = "hx"; };

  home.packages = [ pkgs.godot_4 pkgs.aseprite ];
}

# https://discourse.nixos.org/t/how-do-you-organize-your-configuration/7306/10
# https://discourse.nixos.org/t/how-do-you-organize-dotfiles/12445/2
