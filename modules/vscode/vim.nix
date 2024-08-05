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
  };
}
