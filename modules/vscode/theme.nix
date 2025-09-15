{vscode-marketplace, ...}: {
  programs.vscode = {
    profiles.default.extensions = with vscode-marketplace; [akamud.vscode-theme-onedark];

    profiles.default.userSettings = {
      "editor.fontSize" = 16;
      "terminal.integrated.fontSize" = 16;
      "window.commandCenter" = false;
      "workbench.layoutControl.enabled" = false;
      "workbench.sideBar.location" = "right";
      "editor.fontFamily" = "JetBrains Mono";
      "terminal.integrated.fontFamily" = "JetBrains Mono";
    };
  };
}
