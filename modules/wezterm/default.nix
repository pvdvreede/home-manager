{pkgs, ...}: {
  home.packages = [pkgs.wezterm];

  home.file.weztermConfig = {
    source = pkgs.substituteAll {
      src = ./wezterm.lua;
      zellij_path = "${pkgs.zellij}/bin/zellij";
    };
    target = "/.config/wezterm/wezterm.lua";
  };
}
