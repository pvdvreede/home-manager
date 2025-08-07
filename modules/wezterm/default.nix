{pkgs, ...}: {
  home.packages = [pkgs.wezterm pkgs.jetbrains-mono];

  home.file.weztermConfig = {
    source = pkgs.replaceVars ./wezterm.lua {
      zellij_path = "${pkgs.fish}/bin/fish";
    };
    target = "/.config/wezterm/wezterm.lua";
  };
}
