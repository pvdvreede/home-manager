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
  work = home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsForSystem "aarch64-darwin";
    modules = [
      commonUnfreeModule
      ../../common.nix
      ../../work.nix
      ../../modules/shell
      ../../modules/vscode
      ../../modules/tmux.nix
      ../../modules/helix.nix
      ../../modules/devcontainer.nix
      ../../modules/lazygit.nix
      ../../modules/macappfix.nix
      ../../modules/kitty.nix
      ../../modules/git.nix
      ../../modules/vim.nix
      ../../modules/k9s.nix
      ../../modules/tmux.nix
      ../../modules/jujutsu.nix
      ../../modules/gemini.nix
      {
        home = {
          username = "paulv";
          homeDirectory = "/Users/paulv";
          stateVersion = "24.05";
        };
      }
    ];
    extraSpecialArgs = {
      vscode-marketplace =
        nix-vscode-extensions.extensions.aarch64-darwin.vscode-marketplace;
      nu-scripts = nu-scripts;
    };
  };

  # Alias
  paulv = inputs.self.homeConfigurations.work;
}
