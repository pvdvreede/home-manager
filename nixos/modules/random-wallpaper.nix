{ pkgs, lib, config, ... }:

let
  cfg = config.mine.wallpaper;
  lib = pkgs.lib;
in
{
  options = {
    mine.wallpaper = {
      enable = lib.mkEnableOption "wallpaper";

      workdir = lib.mkOption {
        type = lib.types.path;
        default = ./config/wallpaper;
      };

      resolution = lib.mkOption {
        type = lib.types.string;
        default = "3840x2160";
      };

      category = lib.mkOption {
        type = lib.types.string;
        default = "wallpapers";
      };
    };
  };

  config =
    pkgs.writeShellApplication
      {
        name = "random-wallpaper";
        runtimeInputs = with pkgs; [ feh wget imagemagick ];
        text = ''
          workdir="$HOME/${cfg.workdir}"
          mkdir -p "$workdir"
          wget -O "$workdir"/random.jpg \
            https://source.unsplash.com/${cfg.resolution}/?${cfg.category}

          # create a blurred version
          convert -scale 10% -blur 0x2.5 -resize 1000% "$workdir"/random.jpg "$workdir"/random-blurred.png

          feh --bg-scale "$workdir"/random.jpg
        '';
      };
}
