{ pkgs, ... }:

{
  programs.feh = { enable = true; };

  programs.firefox = {
    enable = true;
    profiles.pvdvreede = { };
  };
}

# https://discourse.nixos.org/t/how-do-you-organize-your-configuration/7306/10
# https://discourse.nixos.org/t/how-do-you-organize-dotfiles/12445/2
