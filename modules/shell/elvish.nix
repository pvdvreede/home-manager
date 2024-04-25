{ pkgs, ... }:

{
  home.packages = with pkgs; [ carapace elvish ];

  home.file = {
    rcelv = {
      executable = false;
      target = "./.config/elvish/rc.elv";
      text = ''
      # completions!
      eval (${pkgs.carapace}/bin/carapace _carapace|slurp)

      set edit:prompt-stale-transform = {|x| styled $x bright-black }
      # set edit:prompt = { pwd }
      set edit:-prompt-eagerness = 5
      # keep rprompt after enter for time
      set edit:rprompt-persistent = $true
      set edit:rprompt = { styled (date) blue }
      set edit:prompt = { (styled (tilde-abbr (pwd)) green) }

      # insert keyboard navigate
      set edit:insert:binding[Ctrl-A] = $edit:move-dot-sol~
      set edit:insert:binding[Ctrl-E] = $edit:move-dot-eol~
      set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~

      fn ll {|@a| e:ls -lah --color $@a }
      fn hms {|@a| e:home-manager switch $@a }
      '';
    };
  };
}