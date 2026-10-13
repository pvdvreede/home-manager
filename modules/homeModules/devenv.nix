{...}: {
  flake.homeModules.devenv = {...}: {
    programs.devenv = {
      enable = true;
    };

    # `devenv shell` (interactive) is a terminal emulator: it openpty()s a new
    # pty and setsid()s the inner shell, so anything started from that shell is
    # never the pane's foreground process. herdr identifies agents from the
    # pane's pty foreground process group, so pi started inside `devenv shell`
    # never shows up in `herdr agent list`.
    #
    # `devenv shell -- <cmd>` instead execs the command in the devenv's own
    # process. `--no-tui` skips the status-line emulator. pi therefore becomes
    # the pane's foreground process and herdr detects it normally (incl. the
    # agent_session ref used for resume).
    programs.fish.functions.pidev = {
      description = "Run pi in the current devenv environment (visible to herdr)";
      body = ''
        if not test -e devenv.nix; and not test -e devenv.yaml
          # No devenv here: fall back to plain pi.
          command pi $argv
          return $status
        end
        command devenv shell --no-tui -- pi $argv
      '';
    };
  };
}
