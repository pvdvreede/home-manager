{...}: {
  flake.homeModules.wezterm = {
    pkgs,
    lib,
    config,
    ...
  }: let
    pi = config.programs.pi-coding-agent.package;
  in {
    programs.wezterm = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin pkgs.emptyDirectory;
    };

    # The GUI app does not inherit the home-manager profile PATH, so every
    # command that wezterm.lua starts uses an absolute store path.
    xdg.configFile."wezterm/wezterm.lua".source = pkgs.replaceVars ./wezterm.lua {
      bash = lib.getExe pkgs.bash;
      pi = lib.getExe pi;
      lazygit = lib.getExe pkgs.lazygit;
      hx = lib.getExe pkgs.helix;
      toolsPath = lib.makeBinPath [
        pkgs.git
        pkgs.worktrunk
        pkgs.coreutils
        pkgs.bash
      ];
    };
  };
}
