{...}: {
  flake.homeModules.herdr = {...}: {
    # Agent integrations are imperative upstream: Herdr writes a state-reporting
    # file into each agent's own config dir and records an embedded
    # `HERDR_INTEGRATION_VERSION` marker, which `herdr integration status`
    # compares against the installed binary. There is no declarative option and
    # no env var that enables them.
    #
    # The Pi integration is vendored declaratively in the pi-coding-agent module
    # (modules/homeModules/pi-coding-agent/default.nix). Any other target must be
    # installed by hand, and re-run after a herdr update if `herdr integration
    # status` reports it outdated:
    #
    #   herdr integration install opencode  # ~/.config/opencode/plugins/herdr-agent-state.js
    #
    # `herdr integration` with no argument lists the other supported targets.
    programs.herdr = {
      enable = true;

      settings = {
        onboarding = false;

        theme = {
          name = "catppuccin";
          auto_switch = true;
          dark_name = "catppuccin";
          light_name = "catppuccin-latte";
        };

        keys = {
          prefix = "ctrl+space";

          # split panes (tmux pneumonics)
          split_horizontal = "prefix+v";
          split_vertical = "prefix+s";

          # new tab
          new_tab = "prefix+c";

          # vim-style pane navigation
          focus_pane_left = "prefix+h";
          focus_pane_down = "prefix+j";
          focus_pane_up = "prefix+k";
          focus_pane_right = "prefix+l";

          new_workspace = "prefix+shift+w";
          # moved off the upstream default to avoid colliding with new_workspace
          rename_workspace = "prefix+shift+e";
          navigate_workspace_up = "ctrl+k";
          navigate_workspace_down = "ctrl+j";
        };

        ui = {
          mouse_capture = true;
          agent_panel_sort = "priority";
          toast.delivery = "herdr";
          sound.enabled = true;
        };

        update.channel = "stable";
      };
    };

    xdg.configFile."opencode/skills/herdr/SKILL.md".source = ./SKILL.md;
  };
}
