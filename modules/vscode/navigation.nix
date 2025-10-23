{
  programs.vscode.profiles.default = {
    keybindings = [
      # Split management
      {
        "key" = "ctrl+\\";
        "command" = "workbench.action.splitEditor";
      }
      {
        "key" = "ctrl+w v";
        "command" = "workbench.action.splitEditorRight";
      }
      {
        "key" = "ctrl+w s";
        "command" = "workbench.action.splitEditorDown";
      }
      {
        "key" = "ctrl+w c";
        "command" = "workbench.action.closeActiveEditor";
      }

      # Move focus between panes (Helix-like hjkl)
      {
        "key" = "ctrl+w h";
        "command" = "workbench.action.focusLeftGroup";
      }
      {
        "key" = "ctrl+w l";
        "command" = "workbench.action.focusRightGroup";
      }
      {
        "key" = "ctrl+w j";
        "command" = "workbench.action.focusBelowGroup";
      }
      {
        "key" = "ctrl+w k";
        "command" = "workbench.action.focusAboveGroup";
      }

      # Move editor group (reordering)
      {
        "key" = "ctrl+shift+h";
        "command" = "workbench.action.moveEditorLeftInGroup";
      }
      {
        "key" = "ctrl+shift+l";
        "command" = "workbench.action.moveEditorRightInGroup";
      }
      {
        "key" = "ctrl+shift+j";
        "command" = "workbench.action.moveEditorLeftInGroup";
      }
      {
        "key" = "ctrl+shift+l";
        "command" = "workbench.action.moveEditorRightInGroup";
      }

      # Tab navigation (mimic Helix buffer cycling)
      {
        "key" = "ctrl+tab";
        "command" = "workbench.action.nextEditorInGroup";
      }
      {
        "key" = "ctrl+shift+tab";
        "command" = "workbench.action.previousEditorInGroup";
      }
    ];
  };
}
