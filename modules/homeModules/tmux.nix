{...}: {
  flake.homeModules.tmux = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
        tmux-fzf
        dotbar
        catppuccin
      ];
      disableConfirmationPrompt = true;
      terminal = "xterm-256color";
      extraConfig = ''
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

        set -g status-position top
        set -g @tmux-dotbar-bg "#1e1e2e"
        set -g @tmux-dotbar-fg "#585b70"
        set -g @tmux-dotbar-fg-current "#cdd6f4"
        set -g @tmux-dotbar-fg-session "#9399b2"
        set -g @tmux-dotbar-fg-prefix "#cba6f7"
      '';
      keyMode = "vi";
      newSession = true;
      prefix = "C-Space";
    };
  };
}
