{pkgs, ...}: {
  home.packages = [pkgs.wezterm pkgs.jetbrains-mono];

  home.file.weztermConfig = {
    source = pkgs.substituteAll {
      src = ./wezterm.lua;
      zellij_path = "${pkgs.tmux}/bin/tmux";
    };
    target = "/.config/wezterm/wezterm.lua";
  };
}
