{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, unzip
}:

let
  pname = "vibekanban";
  version = "0.0.160";
  binaryTag = "v0.0.160-20260122120345";

  # Determine platform-specific values
  platformInfo =
    if stdenv.isLinux && stdenv.isx86_64 then {
      platform = "linux-x64";
      sha256 = "sha256-N8y7XJfMIX8PjdEUJ5nC5mrmLj7s3c1pnc0BvuibXHU=";
    }
    else if stdenv.isLinux && stdenv.isAarch64 then {
      platform = "linux-arm64";
      sha256 = "sha256-hEHNFLFSv8oXBa1dvHBCazbl0bjtY4ztT5yeisXWrw0=";
    }
    else if stdenv.isDarwin && stdenv.isx86_64 then {
      platform = "macos-x64";
      sha256 = "sha256-Xre7tb/qG5ltkrdsljyuooCcdqSFGtVVWE9OmX5pwVk=";
    }
    else if stdenv.isDarwin && stdenv.isAarch64 then {
      platform = "macos-arm64";
      sha256 = "sha256-TNsWvsWOe4Kxni4yke4E8c8JEDEA5dd+abXDTYU5b4g=";
    }
    else throw "Unsupported platform: ${stdenv.system}";

  # Fetch the pre-built binary from the CDN
  src = fetchzip {
    url = "https://npm-cdn.vibekanban.com/binaries/${binaryTag}/${platformInfo.platform}/vibe-kanban.zip";
    sha256 = platformInfo.sha256;
    stripRoot = false;
  };

in stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp vibe-kanban $out/bin/vibe-kanban
    chmod +x $out/bin/vibe-kanban

    runHook postInstall
  '';

  meta = with lib; {
    description = "Vibe Kanban Board - A visual project management tool";
    homepage = "https://github.com/BloopAI/vibe-kanban";
    license = licenses.mit;
    maintainers = [];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}