{inputs, ...}: {
  flake.homeModules.herdr = {
    pkgs,
    lib,
    config,
    ...
  }: let
    herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  in {
    home.packages = [
      herdr
    ];

    programs.kitty.settings.shell = lib.mkForce "${herdr}/bin/herdr";
    programs.ghostty.settings.command = lib.mkForce "${herdr}/bin/herdr";

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
