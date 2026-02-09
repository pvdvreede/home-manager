{...}: {
  programs.yazi = {
    enable = true;
    settings = {
      manager.show_hidden = true;
      manager.sort_by = "alphabetical";
      manager.show_symlink = true;
    };
  };
}
