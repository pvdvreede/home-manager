{ pkgs, ... }:

{
  programs.feh = { enable = true; };

  home.file = {
    wallpaper = {
      target = "bin/wallpaper";
      executable = true;
      text = ''
        #! /usr/bin/env bash

        set -e

        mkdir -p $HOME/.config/wallpaper

        ${pkgs.wget}/bin/wget -O $HOME/.config/wallpaper/random.jpg https://source.unsplash.com/3840x2160/?wallpapers

        ${pkgs.feh}/bin/feh --bg-scale $HOME/.config/wallpaper/random.jpg
      '';
    };
  };
}
