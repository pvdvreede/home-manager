{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    environment = {};
    font.name = "JetBrains Mono";
    font.package = pkgs.jetbrains-mono;
    font.size = 14;
    settings = {
      disable_ligatures = "never";
      window_padding_width = 2;
      confirm_os_window_close = -1;
      remember_window_state = "yes";
    };
    keybindings = {
      "ctrl+shift+n" = "new_tab_with_cwd";
      "ctrl+shift+h" = "previous_tab";
      "ctrl+shift+l" = "next_tab";
    };
  };
}
