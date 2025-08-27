{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ../pkgs/hemux.nix {})
  ];

  programs.helix = {
    enable = true;
    extraPackages = [
      pkgs.docker-compose-language-service
      pkgs.dockerfile-language-server-nodejs
      pkgs.yaml-language-server
    ];
    ignores = [
      "node_modules"
      ".build"
      ".direnv"
    ];
    languages = {
      language-server = {
        yaml-language-server = {
          config.yaml = {
            validation = true;
            schemaStore.enable = true;
            format.enable = true;
          };
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.alejandra}/bin/alejandra";
          };
        }
      ];
    };
    settings = {
      editor = {
        trim-trailing-whitespace = true;
        trim-final-newlines = true;
        true-color = true;
        line-number = "relative";
        mouse = true;
        soft-wrap.enable = true;
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "|";
        };
        whitespace.render = {
          tab = "all";
          newline = "none";
          tabpad = "all";
          space = "all";
        };
        statusline = {
          left = ["spinner" "mode"];
          center = ["file-name" "read-only-indicator" "file-modification-indicator"];
          right = ["version-control" "diagnostics" "file-type"];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = false;
        };
        file-picker = {hidden = false;};
      };
      keys.normal = {
        esc = ["collapse_selection" "keep_primary_selection"];
        "{" = ["goto_prev_paragraph" "collapse_selection"];
        "}" = ["goto_next_paragraph" "collapse_selection"];
        "G" = "goto_file_end";
        "C-p" = "file_picker";
        "C-g" = [":new" ":insert-output ${pkgs.lazygit}/bin/lazygit" ":buffer-close!" ":redraw"];
        "C-r" = ":sh hemux -r";
      };
      keys.select = {
        "{" = ["extend_to_line_bounds" "goto_prev_paragraph"];
        "}" = ["extend_to_line_bounds" "goto_next_paragraph"];
        "G" = "goto_file_end";
      };
      keys.insert = {
        "C-a" = "goto_line_start";
        "C-e" = "goto_line_end";
        "C-d" = ["extend_line_below" "yank" "paste_after" "collapse_selection"];
        "C-k" = ["extend_line_below" "delete_selection"];
        "C-up" = ["extend_line_below" "delete_selection" "move_line_up" "paste_after" "collapse_selection"];
        "C-down" = ["extend_line_below" "delete_selection" "move_line_down" "paste_after" "collapse_selection"];
      };
    };
  };
}
