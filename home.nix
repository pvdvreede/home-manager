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
      "#*"
      "*~"
      ".DS_Store"
      ".netrwhist"
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      color = {
        ui = true;
      };
      push = {
        default = "simple";
      };
      pull = {
        rebase = "preserve";
      };
      branch = {
        autosetuprebase = "always";
      };
      rebase = {
        autosquash = true;
      };
    };

  };
  programs.gh = {
    enable = true;
    enableGitCredentialHelper = true;
  };
  programs.fish = {
    enable = true;
    shellAbbrs = {
      gst = "git status";
      gco = "git checkout";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";

      fig = "docker-compose";
      k = "kubectl";
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
    terminal = "xterm-256color";
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = ''
      # pneumonic for splitting windows
      bind-key v split-window -h
      bind-key s split-window -v
      # vim keybindings for navigation
      bind-key -r h select-pane -L
      bind-key -r j select-pane -D
      bind-key -r k select-pane -U
      bind-key -r l select-pane -R
    '';
    keyMode = "vi";
    newSession = true;
    prefix = "C-Space";
  };
}
