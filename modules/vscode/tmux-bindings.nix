{...}: let
  leader = "ctrl+space";
in {
  programs.vscode.profiles.default = {
    keybindings = [
      # management
      {
        key = "${leader} v";
        command = "workbench.action.splitEditorRight";
      }
      {
        key = "${leader} s";
        command = "workbench.action.splitEditorDown";
      }
      {
        key = "${leader} w";
        command = "workbench.action.closeGroup";
      }
      {
        key = "${leader} d";
        command = "workbench.action.closeAllGroups";
      }

      # movement
      {
        key = "${leader} l";
        command = "workbench.action.focusRightGroup";
      }
      {
        key = "${leader} shift+l";
        command = "workbench.action.moveActiveEditorGroupRight";
      }
      {
        key = "${leader} h";
        command = "workbench.action.focusLeftGroup";
      }
      {
        key = "${leader} shift+h";
        command = "workbench.action.moveActiveEditorGroupLeft";
      }
      {
        key = "${leader} j";
        command = "workbench.action.focusDownGroup";
      }
      {
        key = "${leader} shift+j";
        command = "workbench.action.moveActiveEditorGroupDown";
      }
      {
        key = "${leader} k";
        command = "workbench.action.focusUpGroup";
      }
      {
        key = "${leader} shift+k";
        command = "workbench.action.moveActiveEditorGroupUp";
      }

      # terminal
      {
        key = "${leader} j j";
        command = "workbench.action.terminal.focus";
        when = "!terminalFocus";
      }
      {
        key = "${leader} k";
        command = "workbench.action.focusLastEditorGroup";
        when = "terminalFocus";
      }
      {
        key = "${leader} v";
        command = "workbench.action.terminal.split";
        when = "terminalFocus";
      }
      {
        key = "${leader} r";
        command = "workbench.action.terminal.focusPreviousPane";
        when = "terminalFocus";
      }
      {
        key = "${leader} l";
        command = "workbench.action.terminal.focusNextPane";
        when = "terminalFocus";
      }
    ];
  };
}
