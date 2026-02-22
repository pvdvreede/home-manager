{...}: {
  flake.homeModules.zoxide = {pkgs, ...}: {
    programs.zoxide = {
        enable = true;
    };
  };
}
