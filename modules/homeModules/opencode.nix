{...}: {
  flake.homeModules.opencode = {pkgs, ...}: {
    programs.opencode = {
      enable = true;

      tui = {
        scroll_speed = 3;
        scroll_acceleration = {
          enabled = true;
        };
        diff_style = "auto";
        theme = "catppuccin-frappe";
      };

      settings = {
        autoupdate = false;

        provider = {
          lmstudio = {
            npm = "@ai-sdk/openai-compatible";
            name = "LM Studio";
            options = {
              baseURL = "http://127.0.0.1:1234/v1";
              apiKey = "lmstudio";
            };
            models = {
              "qwen/qwen3-coder-next" = {
                name = "Qwen3 Coder Next";
              };
              "qwen/qwen3.6-35b-a3b" = {
                name = "Qwen3.6";
              };
              "google/gemma-4-31b-qat" = {
                name = "Gemma 4";
              };
            };
          };
        };

        permission = {
          bash = {
            "*" = "ask";
            "git *" = "allow";
            "mkdir *" = "allow";
            "dirname*" = "allow";
            "wc*" = "allow";
            "xargs *" = "allow";
            "nix *" = "allow";
            "ls *" = "allow";
            "find *" = "allow";
            "grep *" = "allow";
            "docker *" = "allow";
            "docker-compose *" = "allow";
            "test *" = "allow";
            "devcontainer *" = "allow";
            "source *" = "allow";
            "just *" = "allow";
            "jj *" = "allow";
            "echo *" = "allow";
            "limactl *" = "allow";
            "diff *" = "allow";
            "yq*" = "allow";
            "jq*" = "allow";
            "lima *" = "allow";
            "head*" = "allow";
            "tail*" = "allow";
            "make *" = "allow";
            "cat *" = "allow";
            "kill *" = "allow";
            "pkill *" = "allow";
            "sort*" = "allow";
            "sleep *" = "allow";
            "sed *" = "allow";
            "cp *" = "allow";
            "true" = "allow";
            "gh *" = "allow";
            "pwd*" = "allow";
            "date *" = "allow";
            "file *" = "allow";
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
          # Allow access to all repos cloned via ghq
          external_directory = {
            "~/ghq/**" = "allow";
          };
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
  };
}
