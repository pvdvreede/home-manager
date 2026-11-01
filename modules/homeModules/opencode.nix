{...}: {
  flake.homeModules.opencode = {pkgs, ...}: {
    programs.opencode = {
      enable = true;

      cli = {
        theme = {
          name = "catppuccin-frappe";
          mode = "system";
        };
        scroll = {
          speed = 3;
          acceleration = true;
        };
        diffs.view = "auto";
      };

      validateFiles = {
        config = true;
        cli = true;
      };

      settings = {
        update = "disable";

        providers = {
          lmstudio = {
            name = "LM Studio";
            package = "@opencode/ai/providers/openai-compatible";
            settings = {
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

        permissions = [
          {
            action = "shell";
            resource = "*";
            effect = "ask";
          }
          {
            action = "shell";
            resource = "git *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "mkdir *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "dirname*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "wc*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "xargs *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "devenv *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "nix *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "nix-env *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "ls *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "find *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "grep *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "docker *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "docker-compose *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "test *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "devcontainer *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "source *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "just *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "jj *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "echo *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "limactl *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "diff *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "yq*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "jq*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "lima *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "head*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "tail*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "make *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "cat *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "kill *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "pkill *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "sort*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "sleep *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "sed *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "cp *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "true";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "pwd*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "date *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "file *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "cut *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "herdr *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "which *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "du *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "rg *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "printf *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "uname *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "python3 *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "python *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "timeout *";
            effect = "allow";
          }
          {
            action = "read";
            resource = "*";
            effect = "allow";
          }
          {
            action = "edit";
            resource = "*";
            effect = "allow";
          }
          {
            action = "glob";
            resource = "*";
            effect = "allow";
          }
          {
            action = "grep";
            resource = "*";
            effect = "allow";
          }
          {
            action = "subagent";
            resource = "*";
            effect = "allow";
          }
          {
            action = "skill";
            resource = "*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/ghq/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "/tmp/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "/nix/store/*";
            effect = "allow";
          }
        ];

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
