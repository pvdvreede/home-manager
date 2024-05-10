{ pkgs, ... }:

{
  home.packages = [ pkgs.fira-code-nerdfont ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding.x = 10;
        padding.y = 10;
      };
      font =
        let family = "FiraCode Nerd Font";
        in {
          normal.family = family;
          normal.style = "Regular";
          bold.family = family;
          bold.style = "Bold";
          italic.family = family;
          italic.style = "Medium";
          size = 12;
        };
      live_config_reload = true;
      shell.program = "elvish";
      shell.args = [ ];
    };
  };
}
