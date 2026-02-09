{...}: {
  programs.vscode.profiles.default = {
    keybindings = [
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
        key = "ctrl+shift+n";
        command = "workbench.action.createTerminalEditor";
      }
      {
        key = "ctrl+shift k";
        command = "workbench.action.terminal.kill";
        when = "terminalFocus";
      }
      {
        command = "workbench.action.toggleSidebarVisibility";
        key = "ctrl+e";
      }
      {
        command = "workbench.files.action.focusFilesExplorer";
        key = "ctrl+e";
        when = "editorTextFocus";
      }
      {
        key = "n";
        command = "explorer.newFile";
        when = "filesExplorerFocus && !inputFocus";
      }
      {
        command = "renameFile";
        key = "r";
        when = "filesExplorerFocus && !inputFocus";
      }
      {
        key = "shift+n";
        command = "explorer.newFolder";
        when = "explorerViewletFocus";
      }
      {
        command = "deleteFile";
        key = "d";
        when = "filesExplorerFocus && !inputFocus";
      }
      {
        key = "alt+w";
        command = "cursorWordRight";
        when = "editorTextFocus";
      }
      {
        key = "alt+b";
        command = "cursorWordLeft";
        when = "editorTextFocus";
      }

      # make things consistent across mac/linux/windows
      {
        key = "ctrl+shift+p";
        command = "workbench.action.showCommands";
      }
      {
        key = "ctrl+p";
        command = "workbench.action.quickOpen";
      }
      {
        key = "ctrl+s";
        command = "workbench.action.files.save";
      }
      {
        key = "ctrl+d";
        command = "editor.action.addSelectionToNextFindMatch";
      }
      {
        key = "ctrl+shift+d";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
    ];
  };
}
