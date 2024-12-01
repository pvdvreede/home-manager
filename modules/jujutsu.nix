{ pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "pvdvreede@gmail.com";
        name = "pvdvreede";
      };
      git = {
        auto-local-bookmark = true;
      };
    };
  };

  home.packages = [ pkgs.lazyjj ];
}
