{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox_dark_hard";
      editor = {
        line-number = "relative";
      };
    };
  };

}
