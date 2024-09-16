{ pkgs, ... }:

{
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
