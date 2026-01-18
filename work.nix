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
}
