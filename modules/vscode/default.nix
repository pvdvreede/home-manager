{ pkgs, vscode-marketplace, ... }:

{
  home.packages = [ pkgs.jetbrains-mono pkgs.source-code-pro ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with vscode-marketplace;
      [
        adamhartford.vscode-base64
        catppuccin.catppuccin-vsc
        hashicorp.terraform
        hashicorp.hcl
        johnpapa.vscode-peacock
        ms-azuretools.vscode-docker
        oderwat.indent-rainbow
        redhat.vscode-yaml
        thenuprojectcontributors.vscode-nushell-lang
        naumovs.color-highlight
        anseki.vscode-color
        jnoortheen.nix-ide
        bierner.markdown-mermaid
        vscodevim.vim
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "remote-containers";
        publisher = "ms-vscode-remote";
        version = "0.329.0";
        sha256 = "6dPTOa2ZlIDF3QDsqBq78e01MSqyQVtWKVIhwhoZWfg=";
      }];
    userSettings = {
      "editor.tabSize" = 2;
      "files.trimTrailingWhitespace" = true;
      "editor.fontSize" = 16;
      "terminal.integrated.fontSize" = 14;
      "files.autoSave" = "onFocusChange";
      "editor.fontFamily" =
        "'JetBrains Mono', 'Source Code Pro', Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "workbench.colorTheme" = "Catppuccin Mocha";
      "editor.wordWrap" = "on";
      "vim.disableExtension" = false;
      "vim.surround" = true;
      "vim.easymotion" = true;
      "vim.smartRelativeLine" = true;
      "vim.leader" = "<Space>";
      "vim.hlsearch" = true;
      "vim.normalModeKeyBindingsNonRecursive" = [
        { before = [ "<S-h>"]; commands = [ ":bprevious" ]; }
        { before = [ "<S-l>" ]; commands = [ ":bnext" ]; }
        { before = [ "leader" "v"]; commands = [ ":vsplit" ]; }
        { before = [ "leader" "s"]; commands = [ ":split" ]; }
        { before = [ "leader" "h"]; commands = [ "workbench.action.focusLeftGroup" ]; }
        { before = [ "leader" "l"]; commands = [ "workbench.action.focusRightGroup" ]; }
        { before = [ "leader" "k"]; commands = [ "workbench.action.focusAboveGroup" ]; }
        { before = [ "leader" "j"]; commands = [ "workbench.action.focusBelowGroup" ]; }
      ];
      "vim.visualModeKeyBindingsNonRecursive" = [
        { before = [ "<" ]; commands = [ "editor.action.outdentLines" ]; }
        { before = [ ">" ]; commands = [ "editor.action.indentLines" ]; }
        { before = [ "J" ]; commands = [ "editor.action.moveLinesDownAction" ]; }
        { before = [ "K" ]; commands = [ "editor.action.moveLinesUpAction" ]; }
        { before = [ "leader" "c" ]; commands = [ "editor.action.commentLine" ]; }
      ];
    };
    userTasks = { };
    keybindings = [
      {
        key = "ctrl+shift+d";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+k";
        command = "editor.action.deleteLines";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+up";
        command = "editor.action.moveLinesUpAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+down";
        command = "editor.action.moveLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+/";
        command = "editor.action.commentLine";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        "key" = "ctrl+shift+a";
        "command" = "workbench.action.terminal.focusNext";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+b";
        "command" = "workbench.action.terminal.focusPrevious";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+j";
        "command" = "workbench.action.togglePanel";
      }
      {
        "key" = "ctrl+shift+n";
        "command" = "workbench.action.terminal.new";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+w";
        "command" = "workbench.action.terminal.kill";
        "when" = "terminalFocus";
      }
      {
        "command" = "workbench.action.toggleSidebarVisibility";
        "key" = "ctrl+e";
      }
      {
        "command" = "workbench.files.action.focusFilesExplorer";
        "key" = "ctrl+e";
        "when" = "editorTextFocus";
      }
      {
        "key" = "n";
        "command" = "explorer.newFile";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "command" = "renameFile";
        "key" = "r";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "key" = "shift+n";
        "command" = "explorer.newFolder";
        "when" = "explorerViewletFocus";
      }
      {
        "command" = "deleteFile";
        "key" = "d";
        "when" = "filesExplorerFocus && !inputFocus";
      }
    ];
  };
}
