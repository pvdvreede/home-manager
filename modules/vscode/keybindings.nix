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
        key = "ctrl+shift+j";
        command = "workbench.action.togglePanel";
      }
      {
        key = "ctrl+shift+n";
        command = "workbench.action.terminal.new";
        when = "terminalFocus";
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

      # --- TMUX-LIKE TERMINAL BINDINGS ---
      # Use Ctrl+Space as the prefix key.
      # Press Ctrl+Space twice to send a real Ctrl+Space to the terminal.
      {
        key = "ctrl+space ctrl+space";
        command = "workbench.action.terminal.sendSequence";
        args = {text = "\u0000";}; # \u0000 is the NUL char for Ctrl+Space
        when = "terminalFocus";
      }

      # --- Pane Splitting ---
      {
        key = "ctrl+space s";
        # OLD: workbench.action.terminal.split
        command = "workbench.action.splitEditor"; # Splits the active editor/terminal vertically
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space v";
        # OLD: workbench.action.terminal.split with args
        command = "workbench.action.splitEditorOrthogonal"; # Splits in the other direction (horizontally)
        when = "editorFocus || terminalFocus";
      }

      # --- Pane Navigation ---
      {
        key = "ctrl+space h";
        # OLD: workbench.action.terminal.focusPreviousPane
        command = "workbench.action.focusLeftGroup";
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space l";
        # OLD: workbench.action.terminal.focusNextPane
        command = "workbench.action.focusRightGroup";
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space j";
        command = "workbench.action.focusAboveGroup";
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space k";
        command = "workbench.action.focusBelowGroup";
        when = "editorFocus || terminalFocus";
      }

      # Unified Closing
      {
        key = "ctrl+space x";
        # OLD: workbench.action.terminal.kill
        command = "workbench.action.closeActiveEditor"; # Closes any active pane
        when = "editorFocus || terminalFocus";
      }

      # --- VIEW & WINDOW MANAGEMENT (Largely Unchanged) ---
      {
        key = "ctrl+space z";
        command = "workbench.action.toggleMaximizedPanel";
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space m";
        command = "workbench.action.toggleTerminalMaximization";
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space n";
        command = "workbench.action.createTerminalEditor"; # Correctly creates terminal in an editor pane
        when = "editorFocus || terminalFocus";
      }
      {
        key = "ctrl+space c";
        command = "workbench.action.createTerminalEditor"; # Correctly creates terminal in an editor pane
        when = "editorFocus || terminalFocus";
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
