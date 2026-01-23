{
  inputs,
  home-manager,
  nixpkgs,
  nix-vscode-extensions,
  nu-scripts,
  plasma-manager,
  pkgsForSystem,
  commonUnfreeModule,
  ...
}: {
  home = home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsForSystem "x86_64-linux";
    modules = [
      commonUnfreeModule
      plasma-manager.homeManagerModules.plasma-manager
      ../../common.nix
      ../../home.nix
      ../../modules/shell
      ../../modules/i3
      ../../modules/vscode
      ../../modules/zellij.nix
      ../../modules/lazygit.nix
      ../../modules/helix.nix
      ../../modules/firefox.nix
      ../../modules/git.nix
      ../../modules/vim.nix
      ../../modules/tmux.nix
      ../../modules/wezterm
      ../../modules/yazi.nix
      ../../modules/jujutsu.nix
      ../../modules/qutebrowser.nix
      {
        home = {
          username = "pvdvreede";
          homeDirectory = "/home/pvdvreede";
          stateVersion = "24.05";
        };
      }
    ];
    extraSpecialArgs = {
      vscode-marketplace =
        nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace;
      nu-scripts = nu-scripts;
    };
  };

  # Alias
  pvdvreede = inputs.self.homeConfigurations.home;
}
