{
  pkgs,
  vscode-marketplace,
  ...
}: {
  home.packages = with pkgs; [
    docker-compose
    docker-client
    lima
    (pkgs.callPackage ./pkgs/vibekanban.nix {})
  ];

  programs.fish.interactiveShellInit = ''
    fish_add_path --global --append /opt/homebrew/bin /opt/homebrew/sbin
  '';
}
