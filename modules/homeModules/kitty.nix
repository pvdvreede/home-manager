{...}: {
  flake.homeModules.kitty = {pkgs, ...}: {
    programs.kitty = {
      enable = true;
      package = null;
      environment = {};
      font.name = "JetBrains Mono";
      font.package = pkgs.jetbrains-mono;
      font.size = 16;
      settings = {
        allow_remote_control = "yes";
        disable_ligatures = "never";
        window_padding_width = 2;
        confirm_os_window_close = -1;
        remember_window_state = "yes";
      };
      keybindings = {
        "ctrl+shift+n" = "new_tab_with_cwd";
        "ctrl+shift+h" = "previous_tab";
        "ctrl+shift+l" = "next_tab";
        "super+enter" = "new_window_with_cwd";
        "ctrl+shift+p" = "command_palette";
        "ctrl+h" = "previous_window";
        "ctrl+l" = "next_window";
      };
    };
  };
}
