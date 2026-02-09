{pkgs, ...}: {
  home.packages = [
    pkgs.devcontainer
  ];

  programs.fish.functions = {
    dc = ''
      if count $argv > 1
        devcontainer $argv[1] --workspace-folder . $argv[2..]
      else if count $argv = 1
        devcontainer $argv[1] --workspace-folder .
      else
        devcontainer
      end
    '';
  };
}
