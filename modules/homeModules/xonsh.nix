{...}: {
  flake.homeModules.xonsh = {pkgs, ...}: {
    home.packages = [pkgs.xonsh];

    home.sessionVariables = {
      SHELL = "${pkgs.xonsh}/bin/xonsh";
    };

    programs.kitty.settings.shell = "${pkgs.xonsh}/bin/xonsh -l";
    programs.ghostty.settings.command = "${pkgs.xonsh}/bin/xonsh -l";
    programs.tmux.shell = "${pkgs.xonsh}/bin/xonsh -l";
  };
}
