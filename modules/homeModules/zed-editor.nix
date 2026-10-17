{...}: {
  flake.homeModules.zed-editor = {
    pkgs,
    lib,
    ...
  }: {
    programs.zed-editor = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
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
        # Load the project's direnv environment (devenv shell) so LSPs and
        # tasks run against per-project toolchains instead of global installs.
        load_direnv = "direct";
        lsp = {
          "rust-analyzer".binary.path_lookup = true;
          clangd.binary.path_lookup = true;
          gopls.binary.path_lookup = true;
          zls.binary.path_lookup = true;
          pyright.binary.path_lookup = true;
          basedpyright.binary.path_lookup = true;
          ruff.binary.path_lookup = true;
        };
      };
    };
  };
}
