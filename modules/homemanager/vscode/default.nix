{ pkgs, vscode-marketplace, ... }:

{
  imports = [ ./dance.nix ./minimalui.nix ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with vscode-marketplace;
      [
        adamhartford.vscode-base64
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
        elves.elvish
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "remote-containers";
        publisher = "ms-vscode-remote";
        version = "0.329.0";
        sha256 = "6dPTOa2ZlIDF3QDsqBq78e01MSqyQVtWKVIhwhoZWfg=";
      }];
    userSettings = {
      "nix.serverSettings" = {
        "nil" = {
          "diagnostics" = {
            "ignored" = [ ];
          };
          "formatting" = {
            "command" = [ "nixpkgs-fmt" ];
          };
        };
      };
      "editor.tabSize" = 2;
      "files.trimTrailingWhitespace" = true;
      "terminal.integrated.profiles.osx" = {
        elvish = {
          path = "${pkgs.elvish}/bin/elvish";
          args = [ ];
        };
      };
      "terminal.integrated.profiles.linux" = {
        elvish = {
          path = "${pkgs.elvish}/bin/elvish";
          args = [ ];
        };
      };
      "terminal.integrated.defaultProfile.osx" = "elvish";
      "terminal.integrated.defaultProfile.linux" = "elvish";
      "files.autoSave" = "onFocusChange";

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
