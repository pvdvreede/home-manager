{ vscode-marketplace, pkgs, ... }:

{
  programs.vscode = {
    extensions = with vscode-marketplace; [ vscodevim.vim ];

    userSettings = {
      "vim.easymotion" = true;
      "vim.hlsearch" = true;
      "vim.leader" = "<space>";
      "vim.disableExtension" = false;
      "vim.useSystemClipboard" = true;

      "vim.statusBarColorControl" = true;
    };

    keybindings = [
      {
        "key" = "ctrl+shift+t";
        "command" = "workbench.action.togglePanel";
      }
      {
        "key" = "ctrl+shift+n";
        "command" = "workbench.action.terminal.new";
        "when" = "terminalFocus";
      }
    ];
  };
}
