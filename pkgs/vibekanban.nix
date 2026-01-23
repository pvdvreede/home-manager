{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, cmake
, stdenv
, darwin
, pnpm
, cacert
, nodejs
}:

let
  pname = "vibekanban";
  version = "0.0.160";

  src = fetchFromGitHub {
    owner = "BloopAI";
    repo = "vibe-kanban";
    rev = "eaecd9db693ddab0256f002b845d93e651802b00";
    sha256 = "0a4b22c2zasmziicwqxlhpynbs6pgvq04r8vdy4crn5a2nq1hngg";
  };

  # Fetch pnpm deps
  pnpmDeps = stdenv.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit version src;
    
    nativeBuildInputs = [ pnpm cacert nodejs ];
    
    installPhase = ''
      export HOME=$PWD/.home
      mkdir -p $HOME
      
      pnpm config set store-dir $out
      
      # Install deps for the whole workspace
      pnpm install --frozen-lockfile --ignore-scripts
    '';
    
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  frontend = stdenv.mkDerivation {
    pname = "${pname}-frontend";
    inherit version src;

    nativeBuildInputs = [ pnpm nodejs ];

    buildPhase = ''
      export HOME=$PWD/.home
      mkdir -p $HOME
      
      pnpm config set store-dir ${pnpmDeps}
      
      # Copy the pnpm-lock.yaml and package.json to avoid issues with read-only source?
      # pnpm install might want to write to node_modules.
      # current dir is a copy of src (writable), so it's fine.
      
      pnpm install --offline --frozen-lockfile --ignore-scripts
      
      cd frontend
      # Binaries are hoisted to root node_modules/.bin
      export PATH="$PWD/../node_modules/.bin:$PATH"
      
      pnpm run build
    '';

    installPhase = ''
      mkdir -p $out/dist
      cp -r dist/* $out/dist
    '';
  };

in rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-cYa6hccUdqJeH06MzGOv3jPwpJA6AKsVupn8QWWGLEw=";

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  preBuild = ''
    mkdir -p frontend/dist
    cp -r ${frontend}/dist/* frontend/dist/
  '';

  postInstall = ''
    mv $out/bin/server $out/bin/vibe-kanban
  '';

  meta = with lib; {
    description = "Vibe Kanban Board";
    homepage = "https://github.com/BloopAI/vibe-kanban";
    license = licenses.mit;
    maintainers = [];
  };
}