{vscode-marketplace, ...}: {
  programs.vscode = {
    profiles.default.extensions = with vscode-marketplace; [
      jasew.vscode-helix-emulation
    ];
  };
}
