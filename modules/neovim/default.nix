# home-manager/neovim.nix
{ pkgs, ... }:
{
  # we need to keep the nvim root config folder out of nix so its readable
  # for lock and config files.
  xdg.configFile."nvim/init.lua" = {
    source = ./nvim/init.lua;
  };

  xdg.configFile."nvim/lua" = {
    source = ./nvim/lua;
  };

  # gcc is needed for the treesitter installation
  home.packages = [pkgs.gcc];
  
  # Enable the Neovim program
  programs.neovim = {
    enable = true;
    # Use the unstable package for potentially newer versions/features
    package = pkgs.neovim-unwrapped; # Or pkgs.neovim for stable

    # Enable default plugins recommended by home-manager
    # defaultEditor = true; # Uncomment if you want Neovim as default $EDITOR
    viAlias = true;     # alias vi=nvim
    vimAlias = true;    # alias vim=nvim

    # Add extra plugins using Nix packages
    plugins = with pkgs.vimPlugins; [
      LazyVim
    ];
  };
}
