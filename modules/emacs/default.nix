{...}: {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs:
      with epkgs; [
        magit
        meow
        ivy
        which-key
        lsp-mode
      ];
  };

  home.file.init-el = {
    target = ".emacs.d/init.el";
    force = true;
    source = ./init.el;
  };

  home.activation.makeEmacsInitMutable = {
    after = ["writeBoundary"];
    before = [];
    data = ''
      userDir="$HOME/.emacs.d"
      file="init.el"
      mv "$userDir/$file" "$userDir/$file.bak"
      cat "$userDir/$file.bak" > "$userDir/$file"
      rm -rf "$userDir/$file.bak"
    '';
  };
}
