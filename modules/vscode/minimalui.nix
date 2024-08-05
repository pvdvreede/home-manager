{ pkgs, vscode-marketplace, ... }:

{
  home.packages = [ pkgs.jetbrains-mono ];

  programs.vscode = {
    extensions = with vscode-marketplace; [ akamud.vscode-theme-onedark ];

    userSettings = {
      "breadcrumbs.enabled" = false;

      "editor.fontSize" = 16;
      "editor.fontFamily" = "JetBrains Mono Medium";
      "editor.fontLigatures" = true;
      "editor.minimap.enabled" = false;
      "editor.padding.bottom" = 15;
      "editor.padding.top" = 15;
      "editor.scrollbar.horizontal" = "hidden";
      "editor.scrollbar.vertical" = "hidden";

      "terminal.integrated.fontSize" = 16;

      "window.zoomLevel" = 0.5;

      "workbench.activityBar.visible" = false;
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
      "workbench.editor.showTabs" = "none";
      "workbench.layoutControl.enabled" = false;
      "workbench.sideBar.location" = "right";
    };
  };
}
