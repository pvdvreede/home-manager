{ pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

    };
  };

  home.file = {
    starshipelv = {
      executable = false;
      target = "./.config/elvish/starship.elv";
      text = ''
        eval (starship init elvish)
      '';
    };
  };
}
