{...}: let
  navySlateTheme = {
    active_border_color = "#005F87";
    inactive_border_color = "#1F232A";
    bell_border_color = "#E06C75";

    # Active tab: Navy background with white text
    active_tab_foreground = "#FFFFFF";
    active_tab_background = "#005F87";
    active_tab_font_style = "bold";

    # Inactive tab: Dark slate background with muted text
    inactive_tab_foreground = "#A8A8A8";
    inactive_tab_background = "#6E6E6E";
    inactive_tab_font_style = "normal";

    # Tab bar background fill
    tab_bar_background = "#181A1F";
  };
in {
  flake.homeModules.kitty = {pkgs, ...}: {
    programs.kitty = {
      enable = true;
      package = null;
      environment = {};
      font.name = "JetBrains Mono";
      font.package = pkgs.jetbrains-mono;
      font.size = 16;
      settings =
        {
          allow_remote_control = "yes";
          disable_ligatures = "never";
          window_padding_width = 0;
          confirm_os_window_close = -1;
          remember_window_state = "yes";
          tab_bar_edge = "top";
          scrollback_lines = 10000;
          tab_bar_style = "powerline";
          window_margin_width = 5;
          window_border_width = "3pt";
          cursor_trail = 300;
          cursor_trail_decay = "0.4 0.6";
          scrollback_pager = "sh -c \"${pkgs.ansifilter}/bin/ansifilter | ${pkgs.helix}/bin/hx\"";
          hide_window_decorations = "titlebar-only";
        }
        // navySlateTheme;
      keybindings = {
        "ctrl+shift+n" = "new_tab_with_cwd";
        "ctrl+shift+h" = "previous_tab";
        "ctrl+shift+l" = "next_tab";
        "super+enter" = "new_window_with_cwd";
        "ctrl+shift+p" = "command_palette";
        "ctrl+h" = "previous_window";
        "ctrl+l" = "next_window";
        "ctrl+shift+q" = "next_layout";
      };
    };
  };
}
