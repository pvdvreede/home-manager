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
    };
  };
}
