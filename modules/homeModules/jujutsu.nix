{...}: {
  flake.homeModules.jujutsu = {...}: {
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

    programs.jjui = {
      enable = true;
      settings.revisions.revset = "all()";
    };
  };
}
