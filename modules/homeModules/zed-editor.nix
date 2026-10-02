{...}: {
  flake.homeModules.zed-editor = {pkgs, ...}: {
    programs.zed-editor = {
      enable = true;
      package = null;
      defaultEditor = false;
      extensions = [
        "nix"
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
