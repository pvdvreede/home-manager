{ ... }:

{
  imports = [ ../polybar ../rofi.nix ];

  home.file = {
    i3 = {
      target = ".config/i3/config";
      source = ./i3conf;
    };
  };

}
