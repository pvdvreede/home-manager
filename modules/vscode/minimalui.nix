{ pkgs, vscode-marketplace, ... }:

{
  home.packages = [ pkgs.fira-code-nerdfont pkgs.inconsolata-nerdfont ];

  programs.vscode = {
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

      "editor.fontSize" = 16;
      "terminal.integrated.fontSize" = 16;

      "editor.fontFamily" = "FiraCode Nerd Font Mono";
      "editor.fontLigatures" = true;
      "editor.padding.top" = 15;
      "editor.padding.bottom" = 15;

      "window.zoomLevel" = 0.3;
    };
  };
}
