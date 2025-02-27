{ pkgs, vscode-marketplace, ... }: {
    programs.vscode = {
      extensions = with vscode-marketplace; [
        jasew.vscode-helix-emulation
      ];
    };

}
