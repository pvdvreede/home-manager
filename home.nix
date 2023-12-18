{ pkgs, ... }:

{
  programs.feh = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    profiles.pvdvreede = {
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding.x = 15;
        padding.y = 15;
      };
      font = let
        family = "JetBrains Mono";
      in {
        normal.family = family;
        normal.style = "Regular";
        bold.family = family;
        bold.style = "Bold";
        italic.family = family;
        italic.style = "MediumItalic";
        size = 12;
      };
      live_config_reload = true;
      shell.program = "fish";
      shell.args = ["-l"];
    };
  };

}

# https://discourse.nixos.org/t/how-do-you-organize-your-configuration/7306/10
# https://discourse.nixos.org/t/how-do-you-organize-dotfiles/12445/2