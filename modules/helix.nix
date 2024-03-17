{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox_dark_hard";
      editor = {
        line-number = "relative";
        mouse = false;
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
        };
      };
      keys.normal = {
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };
}
