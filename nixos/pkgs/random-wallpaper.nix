{pkgs, ...}: let
  wallpaper = pkgs.stdenv.mkDerivation {
    name = "wallpaper";
    src = ./.;
    buildInputs = [pkgs.imagemagick];
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out
      convert -scale 10% -blur 0x2.5 -resize 1000% $src/background.jpg $out/background-blurred.jpg
      cp $src/*.jpg $out/
    '';
  };
in
  pkgs.writeShellApplication {
    name = "run-wallpaper";
    runtimeInputs = [pkgs.feh];
    text = ''
      feh --bg-scale ${wallpaper}/background.jpg
    '';
  }
