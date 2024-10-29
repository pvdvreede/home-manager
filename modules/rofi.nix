{pkgs, ...}: {
  config = {
    home.packages = [pkgs.jetbrains-mono pkgs.rofi-power-menu];

    programs.rofi = {
      enable = true;
      font = "JetBrains Mono";
      theme = "arthur";
      plugins = [pkgs.rofi-power-menu];
      extraConfig = {
        modi = "drun,window,keys,filebrowser";
        window-thumbnail = true;
        show-icons = true;
      };
    };
  };
}
