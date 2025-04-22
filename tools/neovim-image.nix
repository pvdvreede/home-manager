{pkgs ? import <nixpkgs> {}}:
pkgs.dockerTools.buildImage {
  name = "neovim-dev";
  tag = "latest";
  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = with pkgs; [
      coreutils
      nix
      bash
      fish
      git
      neovim

      vimPlugins.LazyVim
      ripgrep
      (nerdfonts.override {fonts = ["FiraCode"];})
      fd
      gcc
      lazygit
    ];
    pathsToLink = ["/bin"];
  };
}
