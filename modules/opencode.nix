{
  pkgs,
  lib,
  ...
}: {
  programs.opencode = {
    enable = true;

    rules = ''
      ## general development rules
      - when planning a change, optimise for small, easy to review changes. This means trying to split changes across multiple PRs without breaking tests or compilation.
    '';

    commands = {
      create-pr = ''
        # create pull request

        generate a new pull request for this work, make sure:
        - main is up-to-date with the origin/main branch
        - this work is on its own branch
        - this work's branch is rebased with main
      '';
    };

    # Global OpenCode configuration
    settings = {
      "$schema" = "https://opencode.ai/config.json";

      # Theme
      theme = "opencode";

      # Auto-update enabled
      autoupdate = true;

      # TUI settings
      tui = {
        scroll_speed = 3;
        scroll_acceleration = {
          enabled = true;
        };
        diff_style = "auto";
      };

      # Permissions - require approval for dangerous operations
      permission = {
        bash = "ask";
        edit = "allow";
        write = "allow";
        skill = "allow";
      };

      # File watcher ignore patterns
      watcher = {
        ignore = [
          "node_modules/**"
          "dist/**"
          ".git/**"
          "target/**"
          "result/**"
        ];
      };
    };
  };
}
