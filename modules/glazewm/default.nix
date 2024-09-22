{...}: {
  home.file.glazewmconfig = {
    enable = true;
    source = ./config.yaml;
    target = "/.config/glzr/config.yaml";
  };

  # we need to copy this to the windows side outside of the home dir
  home.activation.copyGlazeWMFile = {
    after = ["writeBoundary"];
    before = [];
    data = ''
      cp $HOME/.config/glzr/config.yaml /mnt/c/Users/pvdvreede/.glzr/glazewm/
    '';
  };
}
