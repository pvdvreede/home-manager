{
  stdenv,
  fetchFromGitHub,
  nodejs,
}:

let
  version = "1.0.21";
in
stdenv.mkDerivation {
  pname = "context-mode";
  inherit version;

  src = fetchFromGitHub {
    owner = "mksglu";
    repo = "context-mode";
    rev = "v${version}";
    hash = "sha256-CxeZw9Joc4jRO9pV8/TmmDrPnXl0t47WDyUGfmJwN/8=";
  };

  buildInputs = [ nodejs ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp cli.bundle.mjs server.bundle.mjs start.mjs $out/lib/
    cat > $out/bin/context-mode << EOF
#!/bin/sh
exec ${nodejs}/bin/node "$out/lib/start.mjs" "$@"
EOF
    chmod +x $out/bin/context-mode
  '';
}
