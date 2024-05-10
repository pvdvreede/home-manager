{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
    extraLuaConfig = ''
    plugins = {

    }
    require("lazy").setup(plugins, {})
    '';
  };
}
