{pkgs, ...}: {
  programs.helix = {
    enable = true;
    extraPackages = [
      pkgs.yaml-language-server
    ];
    ignores = [
      "node_modules"
      ".build"
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
      theme = "curzon";
      editor = {
        line-number = "relative";
        mouse = true;
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
          display-inlay-hints = true;
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
      };
    };
  };
}
