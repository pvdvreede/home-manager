{...}: {
  flake.homeModules.claude = {pkgs, ...}: {
    programs.claude-code = {
      enable = true;
    };
  };
}
