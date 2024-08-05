{ vscode-marketplace, ... }:

{
  programs.vscode = {
    extensions = with vscode-marketplace; [ gregoire.dance ];

    userSettings = {
      "dance.modes" = {
        "normal" = {
          cursorStyle = "block";
          selectionBehavior = "character";
        };
      };
    };

    keybindings = [{
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
    }];
  };
}
