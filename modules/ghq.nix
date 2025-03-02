{pkgs, ...}: {
  home.packages = [pkgs.ghq];

  programs.fish.shellInit = ''
    bind \cf 'gz; commandline -f repaint'
  '';

  programs.fish.functions.gz = {
    body = ''
      cd ~/ghq/(${pkgs.ghq}/bin/ghq list | ${pkgs.fzf}/bin/fzf)
    '';
  };
}
