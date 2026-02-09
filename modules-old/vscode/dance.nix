{vscode-marketplace, ...}: {
  programs.vscode = {
    profiles.default.extensions = with vscode-marketplace; [gregoire.dance];

    profiles.default.userSettings = {
      "dance.modes" = {
        "normal" = {
          cursorStyle = "block";
          selectionBehavior = "character";
        };
      };
    };

    profiles.default.keybindings = [
      {
        "key" = "m";
        "command" = "dance.openMenu";
        "when" = "editorTextFocus && dance.mode == 'normal'";
        "args" = {
          "menu" = {
            "items" = {
              "i" = {
                "text" = "select inside";
                "command" = "dance.seek.askObject.inner";
              };
              "a" = {
                "text" = "select around";
                "command" = "dance.seek.askObject";
              };
              "m" = {
                "text" = "goto matching bracket";
                "command" = "dance.seek.enclosing";
              };
            };
          };
        };
      }
    ];
  };
}
