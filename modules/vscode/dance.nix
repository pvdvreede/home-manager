{ vscode-marketplace, ... }:

{
  programs.vscode = {
    extensions = with vscode-marketplace; [
      gregoire.dance
    ];

    userSettings = {
      "dance.modes" = {
        "normal" = {
          cursorStyle = "block";
          selectionBehavior = "character";
        };
      };
    };
  };
}
