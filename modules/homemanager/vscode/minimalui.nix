{ pkgs, vscode-marketplace, ... }:

{
  home.packages = [ pkgs.jetbrains-mono ];

  programs.vscode = {
    extensions = with vscode-marketplace; [
      akamud.vscode-theme-onedark
    ];

    userSettings = {
      "breadcrumbs.enabled" = false;

      "editor.fontFamily" = "JetBrains Mono Medium";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 16;
      "editor.minimap.enabled" = false;
      "editor.padding.bottom" = 15;
      "editor.padding.top" = 15;
      "editor.scrollbar.horizontal" = "hidden";
      "editor.scrollbar.vertical" = "hidden";

      "terminal.integrated.fontSize" = 16;

      "window.menuBarVisibility" = "toggle";
      "window.zoomLevel" = 0.5;

      "workbench.activityBar.visible" = false;
      "workbench.colorTheme" = "Atom One Dark";
      "workbench.editor.showTabs" = "none";
      "workbench.layoutControl.enabled" = false;
      "workbench.sideBar.location" = "right";
    };
  };
}
