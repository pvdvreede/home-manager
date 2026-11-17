{...}: {
  flake.homeModules.wezterm = {
    pkgs,
    lib,
    ...
  }: {
    programs.wezterm = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin pkgs.emptyDirectory;
    };

    xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  };
}
