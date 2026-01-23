{
  inputs,
  home-manager,
  nixpkgs,
  nix-vscode-extensions,
  nu-scripts,
  pkgsForSystem,
  commonUnfreeModule,
  ...
}: {
  wsl = home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsForSystem "x86_64-linux";
    modules = [
      commonUnfreeModule
      ../../common.nix
      ../../modules/direnv.nix
      ../../modules/shell
      ../../modules/devcontainer.nix
      ../../modules/lazygit.nix
      ../../modules/i3
      ../../modules/vscode
      ../../modules/helix.nix
      ../../modules/jujutsu.nix
      ../../modules/kitty.nix
      ../../modules/git.nix
      ../../modules/gemini.nix
      {
        home = {
          username = "nixos";
          homeDirectory = "/home/nixos";
          stateVersion = "24.05";
          packages = [
            (inputs.self.packages.x86_64-linux.vibekanban)
          ];
        };
        programs.home-manager.enable = true;
      }
    ];
    extraSpecialArgs = {
      vscode-marketplace =
        nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace;
      nu-scripts = nu-scripts;
    };
  };
}
