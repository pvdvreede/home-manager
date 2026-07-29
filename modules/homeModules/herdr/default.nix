{inputs, ...}: {
  flake.homeModules.herdr = {pkgs, ...}: let
    herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  in {
    home.packages = [
      herdr
    ];

    xdg.configFile."herdr/config.toml" = {
      source = ./config.toml;
    };

    xdg.configFile."opencode/skills/herdr/SKILL.md" = {
      source = ./SKILL.md;
    };

    home.sessionVariables = {
      HERDR_INTEGRATIONS = "opencode";
    };
  };
}
