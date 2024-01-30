{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.rustPlatform.buildRustPackage {
  name = "dotree";
  src = pkgs.fetchFromGitHub {
    owner = "KnorrFG";
    repo = "dotree";
    rev = "0.5.2";
    sha256 = "y+1YkvFQblry4JhSDLKUprW2jLHKOC0HiHgTU8867Ck=";
  };
  cargoSha256 = "9BHR0YiWjcqtFUg2e6MuX+l2qSt8cU9zrWJ4ekJAFg0=";
}
