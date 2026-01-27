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

      start-fresh = ''
        # start a fresh task

        lets start a fresh task:
        - stash any changed files
        - get main branch up-to-date with the origin/main branch
        - create a new branch, or if the repo is jujutsu enabled, start a fresh change
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

      permission = {
        bash = {
          "*" = "ask";
          "git *" = "allow";
          "mkdir *" = "allow";
          "nix *" = "allow";
          "ls *" = "allow";
          "find *" = "allow";
          "grep *" = "allow";
          "docker *" = "allow";
          "docker-compose *" = "allow";
          "devcontainer *" = "allow";
          "jj *" = "allow";
          "echo *" = "allow";
          "limactl *" = "allow";
          "head *" = "allow";
          "tail *" = "allow";
          "make *" = "allow";
          "cat *" = "allow";
        };
        edit = "allow";
        grep = "allow";
        task = "allow";
        lsp = "allow";
        read = "allow";
        glob = "allow";
        write = "allow";
        list = "allow";
        skill = "allow";
      };

      # File watcher ignore patterns
      watcher = {
        ignore = [
          "node_modules/**"
          "dist/**"
          ".git/**"
          ".jj/**"
          "target/**"
          "result/**"
        ];
      };
    };
  };
}
