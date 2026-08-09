{...}: {
  flake.homeModules.ghostty = {...}: {
    programs.ghostty = {
      enable = true;
      package = null;
      settings = {
        scrollbar = "never";
        font-size = 16;
        window-padding-x = 5;
        window-padding-y = 5;
        keybind = [
          "ctrl+space>n=new_tab"
          "ctrl+space>v=new_split"
        ];
      };
    };
  };
}
