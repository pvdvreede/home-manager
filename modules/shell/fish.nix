{pkgs, ...}: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship.enableFishIntegration = true;

  programs.tmux.shell = "${pkgs.fish}/bin/fish";

  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      {
        name = "z";
        src = z.src;
      }
    ];
    functions = {
      # fish_prompt = {
      #   body = ''
      #     set_color purple;
      #     echo (pwd) '>' (set_color normal);
      #   '';
      # };
      envsource = {
        body = ''
          for line in (cat $argv | grep -v '^#')
            set item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
            echo "Exported key $item[1]"
          end
        '';
      };
    };
    shellAliases = {
      ll = "ls -lah";
      fig = "docker compose";
      gst = "git status";
      gco = "git checkout";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gdca = "git diff --cached";
      gpom = "git push origin main";
      ns = "nix search nixpkgs";
      nsh = "nix-shell -p";

      hms = "home-manager switch";
      lz = "lazygit";
    };
    interactiveShellInit = ''
      set -gx EDITOR hx

      if test -e ~/.custom.fish
        source ~/.custom.fish
      end

      # taken from
      # https://github.com/kidonng/nix.fish/blob/master/conf.d/nix.fish
      set --local profile ~/.nix-profile
      set --local default /nix/var/nix/profiles/default

      set --local channels ~/.nix-defexpr/channels
      contains $channels $NIX_PATH || set --global --export --append NIX_PATH $channels

      function _nix_install --on-event nix_install --inherit-variable profile
          set --universal --export NIX_PROFILES $profile

          if test -d $default && ! contains $default $NIX_PROFILES
              set --prepend NIX_PROFILES $default
          end

          # Also check for /etc/ssl/cert.pem, see https://github.com/NixOS/nix/issues/5461
          for file in /etc/{ssl/{certs/ca-certificates.crt,ca-bundle.pem,certs/ca-bundle.crt},pki/tls/certs/ca-bundle.crt,ssl/cert.pem} $profile/etc/{ssl/certs/,}ca-bundle.crt
              if test -e $file
                  set --universal --export NIX_SSL_CERT_FILE $file
                  break
              end
          end
      end

      function _nix_uninstall --on-event nix_uninstall
          set --erase NIX_{PATH,PROFILES,SSL_CERT_FILE}
          functions --erase _nix_{,un}install
      end

      test -n "$MANPATH" && set --prepend MANPATH $profile/share/man

      set --local packages (string match --regex "/nix/store/[\w.-]+" $PATH)
      fish_add_path --global --append $packages/bin $profile/bin $default/bin

      if test (count $packages) != 0
          set fish_complete_path $fish_complete_path[1] \
              $packages/etc/fish/completions \
              $packages/share/fish/vendor_completions.d \
              $fish_complete_path[2..]
          set fish_function_path $fish_function_path[1] \
              $packages/etc/fish/functions \
              $packages/share/fish/vendor_functions.d \
              $fish_function_path[2..]

          for file in $packages/etc/fish/conf.d/*.fish $packages/share/fish/vendor_conf.d/*.fish
              if ! test -f (string replace --regex "^.*/" $__fish_config_dir/conf.d/ -- $file)
                  source $file
              end
          end
      end
    '';
  };
}
