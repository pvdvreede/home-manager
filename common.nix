{ config, pkgs, vscode-marketplace, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);

  home.packages = [
    pkgs.obsidian
    pkgs.tree
    pkgs.jetbrains-mono
    pkgs.source-code-pro
    pkgs.nil
    pkgs.nixpkgs-fmt
  ];

  # # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    nixconfig = {
      executable = false;
      text = "{ allowUnfree = true; }";
      target = ".config/nixpkgs/config.nix";
    };
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/pvdvreede/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = pkgs.lib.mkDefault "vim";
    TERMINAL = "alacritty";
  };

  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userEmail = "pvdvreede@gmail.com";
    userName = "pvdvreede";
    ignores =
      [ "#*" "*~" ".DS_Store" ".netrwhist" "*.swp" ".vscode/settings.json" ];
    extraConfig = {
      init = { defaultBranch = "main"; };
      color = { ui = true; };
      push = { default = "current"; };
      branch = { autosetuprebase = "always"; };
      rebase = { autosquash = true; };
      pull.rebase = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      # Workaround for https://github.com/nix-community/home-manager/issues/4744
      version = 1;
    };
  };

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

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [ catppuccin tmux-fzf ];
    disableConfirmationPrompt = true;
    terminal = "xterm-256color";
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = ''
      set -g status-position top

      # stop delay in esc key for helix
      set -sg escape-time 0

      # pneumonic for splitting windows
      bind-key v split-window -h
      bind-key s split-window -v
      # vim keybindings for navigation
      bind-key -r h select-pane -L
      bind-key -r j select-pane -D
      bind-key -r k select-pane -U
      bind-key -r l select-pane -R

      # catppuccin theme config
      set -g @catppuccin_flavour 'latte'
      set -g @catppuccin_window_tabs_enabled on
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
      set -g @catppuccin_host "on"
      set -g @catppuccin_user "on"
    '';
    keyMode = "vi";
    newSession = true;
    prefix = "C-Space";
  };
}
