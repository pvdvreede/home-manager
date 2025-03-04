{
  stdenv,
  fetchurl,
}: let
  version = "v0.0.35";
  os = stdenv.hostPlatform.parsed.kernel.name;
  arch =
    if stdenv.hostPlatform.parsed.cpu.name == "aarch64"
    then "arm64"
    else stdenv.hostPlatform.parsed.cpu.name;
in
  stdenv.mkDerivation {
    pname = "rye";
    version = "${version}";
    src = fetchurl {
      url = "https://github.com/refaktor/rye/releases/download/${version}/rye_${os}_${arch}.tar.gz";
      hash = "sha256-+a2rtLSnZcjzc5VbrBzUzS4G9btC/VtXQHUFu1CDkGw=";
    };

    unpackPhase = ''
      tar -xvzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp rye $out/bin/
    '';
  }
