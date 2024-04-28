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

        workdir="$HOME/.config/wallpaper"

        mkdir -p $workdir

        ${pkgs.wget}/bin/wget -O $workdir/random.jpg https://source.unsplash.com/3840x2160/?wallpapers

        # create a lock screen version
        ${pkgs.imagemagick}/bin/convert -scale 10% -blur 0x2.5 -resize 1000% $workdir/random.jpg $workdir/random-blurred.png

        ${pkgs.feh}/bin/feh --bg-scale $HOME/.config/wallpaper/random.jpg
      '';
    };
  };
}
