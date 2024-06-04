{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "pop-dark";
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
          left = [ "spinner" "mode" ];
          center = [ "file-name" "read-only-indicator" "file-modification-indicator" ];
          right = [ "version-control" "diagnostics" "file-type" ];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        file-picker = {
          hidden = false;
        };
      };
      keys.normal = {
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };
}
