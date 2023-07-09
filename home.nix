{ config, pkgs, ... }:

{
  home.username = "pvdvreede";
  home.homeDirectory = "/home/pvdvreede";

  home.stateVersion = "23.05";

  home.packages = [

  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
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
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "pvdvreede@gmail.com";
    userName = "pvdvreede";
    ignores = [
      ".DS_store"
    ];
  };
  programs.fish = {
    enable = true;
    shellAbbrs = {
      gst = "git status";
      gco = "git checkout";
      ga = "git add";
      gc = "git commit";
    };
  };
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      ctrlp
      vim-airline
      vim-move
      vim-nix
    ];
    settings = {
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };
    extraConfig = ''
      let g:move_key_modifier = 'C'
      autocmd BufWritePre * :%s/\s\+$//e
    '';
  };
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    extraConfig = "";
    keyMode = "vi";
    newSession = true;
    prefix = "C-Space";
  };
}
