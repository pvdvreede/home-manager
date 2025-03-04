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
  sha = {
    "x86_64-linux" = "sha256-BbT84ry/7zl8GI1dfl0ZC3/rDZizA/oZtOUKUqGjfLI=";
    "aarch64-darwin" = "sha256-+a2rtLSnZcjzc5VbrBzUzS4G9btC/VtXQHUFu1CDkGw=";
  };
in
  stdenv.mkDerivation {
    pname = "rye";
    version = "${version}";
    src = fetchurl {
      url = "https://github.com/refaktor/rye/releases/download/${version}/rye_${os}_${arch}.tar.gz";
      hash = sha.${stdenv.hostPlatform.system};
    };

    unpackPhase = ''
      tar -xvzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp rye $out/bin/
    '';
  }
