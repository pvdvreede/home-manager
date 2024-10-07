{pkgs}: let
  version = "v0.14.2-Beta";
in
  pkgs.stdenv.mkDerivation {
    name = "aerospace";
    inherit version;
    system = "aarch64-darwin";
    src = pkgs.fetchzip {
      url = "https://github.com/nikitabobko/AeroSpace/releases/download/${version}/AeroSpace-${version}.zip";
      sha256 = "sha256-v2D/IV9Va0zbGHEwSGt6jvDqQYqha290Lm6u+nZTS3A=";
    };
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/Applications
      cp -R $src/AeroSpace.app $out/Applications/
    '';
  }
