{...}: {
  flake.homeModules.zed-editor = {
    pkgs,
    lib,
    ...
  }: {
    programs.zed-editor = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.isDarwin null;
      defaultEditor = false;
      extensions = [
        "nix"
        "toml"
        "dockerfile"
        "terraform"
        "elixir"
      ];
      userSettings = {
        buffer_font_size = 16;
        features = {
          copilot = false;
        };
        telemetry = {
          metrics = false;
        };
        ui_font_size = 16;
        vim_mode = false;
      };
    };
  };
}
