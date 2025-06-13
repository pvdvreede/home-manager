{
  pkgs,
}: let
  version = "v1.2.0";
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = "tweety";
    version = "${version}";
    src = pkgs.fetchurl {
      url = "https://github.com/pomdtr/tweety/releases/download/v1.2.0/tweety-1.2.0-linux_amd64.tar.gz";
      hash = "";
    };

    unpackPhase = ''
      tar -xvzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp * $out/bin/
    '';
  }
