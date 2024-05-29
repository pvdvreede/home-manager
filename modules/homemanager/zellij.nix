{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "${pkgs.elvish}/bin/elvish";
      pane_frames = false;
      theme = "dracula";
      keybinds = {
        normal = {
          unbind = "Ctrl b";
        };
      };
    };
  };
}
