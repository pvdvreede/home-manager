{...}: {
  flake.homeModules.granted = {pkgs, ...}: {
    home.packages = [pkgs.granted];

    programs.fish.functions.assume = {
      body = ''
        source ${pkgs.granted}/share/assume.fish $argv
      '';
    };
  };
}
