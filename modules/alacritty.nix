{ pkgs, ... }:

{
  home.packages = [
    pkgs.jetbrains-mono
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding.x = 15;
        padding.y = 15;
      };
      font = let family = "JetBrains Mono";
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
      shell.args = [ "-l" ];
    };
  };
}
