{pkgs, ...}: let
  floax = pkgs.fetchFromGitHub {
    owner = "omerxx";
    repo = "tmux-floax";
    rev = "61c7f466b9a4ceed56f99d403250164170d586cd";
    hash = "sha256-DOwn7XEg/L95YieUAyZU0FJ49vm2xKGUclm8WCKDizU=";
  };
  session = pkgs.fetchFromGitHub {
    owner = "omerxx";
    repo = "tmux-sessionx";
    rev = "42c18389e73b80381d054dd1005b8c9a66942248";
    hash = "sha256-SRKI4mliMSMp/Yd+oSn48ArbbRA+szaj70BQeTd8NhM=";
  };
  minimalStatus = pkgs.fetchFromGitHub {
    owner = "niksingh710";
    repo = "minimal-tmux-status";
    rev = "d7188c1aeb1c7dd03230982445b7360f5e230131";
    hash = "sha256-JtbuSxWFR94HiUdQL9uIm2V/kwGz0gbVbqvYWmEncbc=";
  };
in {
  home.packages = [
    pkgs.fzf
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      tmux-fzf
      {
        plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "floax";
          version = "main";
          src = floax;
        };
      }
      {
        plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "sessionx";
          version = "main";
          src = session;
        };
        extraConfig = ''
          set -g @sessionx-bind 'o'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "minimal";
          version = "main";
          src = minimalStatus;
        };
      }
    ];
    disableConfirmationPrompt = true;
    terminal = "xterm-256color";
    extraConfig = ''
      set -g status-position top

      # stop delay in esc key for helix
      set -sg escape-time 0

      # pneumonic for splitting windows
      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key s split-window -v -c "#{pane_current_path}"
      bind-key c new-window -c "#{pane_current_path}"
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
