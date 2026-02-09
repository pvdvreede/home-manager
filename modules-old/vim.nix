{ pkgs, ... }:

{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      catppuccin-vim
      ctrlp
      vim-airline
      vim-commentary
      vim-easy-align
      vim-elixir
      vim-expand-region
      vim-move
      vim-nix
      vim-terraform
      vim-visual-multi
      vim-yaml
      vimux
    ];
    settings = {
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };
    extraConfig = ''
      let mapleader=","
      autocmd BufWritePre * :%s/\s\+$//e
      set noswapfile

      " show whitespace chars
      set listchars=tab:!·,trail:·
      set list

      " vim-move
      let g:move_key_modifier = 'C'
      let g:move_key_modifier_visualmode = 'C'

      " catppucin theme
      set termguicolors
      let g:airline_theme = 'catppuccin_mocha'
      colorscheme catppuccin_mocha

      " vimux config
      let g:VimuxOrientation = "h"
      let g:VimuxHeight = "30"
      let g:VimuxCloseOnExit = 1
      nnoremap <leader>vn :VimuxPromptCommand<cr>
      nnoremap <leader>vr :VimuxRunLastCommand<cr>
      nnoremap <leader>vc :VimuxCloseRunner<cr>
    '';
  };

  home.sessionVariables = {
    EDITOR = pkgs.lib.mkDefault "vim";
  };
}
