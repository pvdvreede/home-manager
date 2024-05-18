{ vscode-marketplace, ... }:

{
  programs.vscode = {
    extensions = with vscode-marketplace; [
      gregoire.dance
    ];
  };
}
