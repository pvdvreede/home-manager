{pkgs, ...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "pvdvreede@gmail.com";
        name = "pvdvreede";
      };
      remotes = {
        origin.auto-track-bookmarks = "glob:*";
      };
    };
  };

  home.packages = [pkgs.jjui];
}
