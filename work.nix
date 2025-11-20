{pkgs, ...}: {
  home.packages = with pkgs; [
    docker-compose
    docker-client
    lima
  ];
}
