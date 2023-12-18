{ pkgs, vscode-marketplace, ... }:

{
  home.packages = [
    pkgs.jetbrains-mono
    pkgs.source-code-pro
  ];

  programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      extensions = with vscode-marketplace; [
        adamhartford.vscode-base64
        catppuccin.catppuccin-vsc
        hashicorp.terraform
        johnpapa.vscode-peacock
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-containers
        oderwat.indent-rainbow
        redhat.vscode-yaml
        thenuprojectcontributors.vscode-nushell-lang
        naumovs.color-highlight
        anseki.vscode-color
        vscodevim.vim
        jnoortheen.nix-ide
      ];
      userSettings = {
        "editor.tabSize" = 2;
        "files.trimTrailingWhitespace" = true;
        "editor.fontSize" = 16;
        "terminal.integrated.fontSize" = 14;
        "files.autoSave" = "onFocusChange";
        "editor.fontFamily" = "'JetBrains Mono', 'Source Code Pro', Menlo, Monaco, 'Courier New', monospace";
        "editor.fontLigatures" = true;
        "workbench.colorTheme" = "Catppuccin Mocha";
        "editor.wordWrap" = "on";
        "vim.disableExtension" = false;
        "vim.surround" = true;
        "vim.smartRelativeLine" = true;
      };
      userTasks = {};
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
      ];
    };
}