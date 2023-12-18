{ pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.jetbrains-mono ];

    programs.rofi = {
      enable = true;
      font = "JetBrains Mono";
      theme = "arthur";
      extraConfig = {
        modi = "drun,window,keys,filebrowser";
        window-thumbnail = true;
        show-icons = true;
      };
    };
  };
}
