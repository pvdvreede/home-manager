{ pkgs, vscode-marketplace, ... }:

{
  home.packages = [ pkgs.jetbrains-mono ];

  programs.vscode = {
    extensions = with vscode-marketplace; [
      akamud.vscode-theme-onedark
    ];

    userSettings = {
      "breadcrumbs.enabled" = false;
      "editor.minimap.enabled" = false;
      "workbench.sideBar.location" = "right";
      "workbench.activityBar.visible" = false;
      "workbench.layoutControl.enabled" = false;
      "editor.scrollbar.horizontal" = "hidden";
      "editor.scrollbar.vertical" = "hidden";
      "window.menuBarVisibility" = "toggle";
      "workbench.editor.showTabs" = "none";

      "terminal.integrated.fontSize" = 16;

      "editor.fontSize" = 16;
      "editor.fontFamily" = "JetBrains Mono Medium";
      "editor.fontLigatures" = true;
      "editor.padding.top" = 15;
      "editor.padding.bottom" = 15;

      "window.zoomLevel" = 0.5;

      "workbench.colorTheme" = "Atom One Dark";
      "workbench.colorCustomizations" = {
        "editorOverviewRuler.border" = "#0000";
        "editorOverviewRuler.findMatchForeground" = "#fff4";
        "editorOverviewRuler.rangeHighlightForeground" = "#0000";
        "editorOverviewRuler.selectionHighlightForeground" = "#0000";
        "editorOverviewRuler.wordHighlightForeground" = "#0000";
        "editorOverviewRuler.wordHighlightStrongForeground" = "#0000";
        "editorOverviewRuler.modifiedForeground" = "#0000";
        "editorOverviewRuler.addedForeground" = "#0000";
        "editorOverviewRuler.deletedForeground" = "#0000";
        "editorOverviewRuler.errorForeground" = "#0000";
        "editorOverviewRuler.warningForeground" = "#0000";
        "editorOverviewRuler.infoForeground" = "#0000";
        "editorOverviewRuler.bracketMatchForeground" = "#0000";
    };
    };
  };
}
