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
      set edit:-prompt-eagerness = 5
      # keep rprompt after enter for time
      set edit:rprompt-persistent = $true
      set edit:rprompt = { styled (date) blue }
      set edit:prompt = { styled (tilde-abbr (pwd)) green; styled ' > ' white }

      # insert keyboard navigate
      set edit:insert:binding[Ctrl-A] = $edit:move-dot-sol~
      set edit:insert:binding[Ctrl-E] = $edit:move-dot-eol~
      set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~

      fn ll {|@a| e:ls -lah --color $@a }
      fn hms {|@a| e:home-manager switch $@a }
      fn fig {|@a| e:docker-compose $@a }
      fn k {|@a| e:kubectl $@a }


      set E:EDITOR = "hx"

      # make sure nix is in the path
      set paths = (conj $paths $E:HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin /usr/local/bin /opt/homebrew/bin)
      '';
    };
  };
}
