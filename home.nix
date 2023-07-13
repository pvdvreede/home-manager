{ pkgs, ... }:

{
  home.file = {
    wezterm = {
      enable = true;
      executable = false;
      source = ./wezterm.lua;
      target = "../../mnt/c/Users/pvdvreede/.wezterm.lua";
    };
  };
}
