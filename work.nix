{
  pkgs,
  vscode-marketplace,
  ...
}: {
  home.packages = with pkgs; [
    docker-compose
    docker-client
    lima
  ];

  programs.vscode.profiles.default.extensions = with vscode-marketplace; [
    sourcegraph.amp
    anthropic.claude-code
  ];
}
