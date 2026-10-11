{...}: {
  flake.homeModules.pi-coding-agent = {
    pkgs,
    lib,
    ...
  }: let
    # Extensions authored here and owned by Home Manager. Drop `.ts`/`.js` files
    # (or directories containing `index.ts`) into ./extensions and they are
    # copied into the Nix store and listed by absolute path in settings.json.
    # Pi loads them in place and aliases `@earendil-works/pi-*` and `typebox`,
    # so plain files with no node_modules work.
    #
    # Do NOT also place these under ~/.pi/agent/extensions/: Pi auto-discovers
    # that directory too and would load each one a second time.
    extensionsDir = ./extensions;
    extensions = map (name: extensionsDir + "/${name}") (
      builtins.attrNames (
        lib.filterAttrs
        (name: type: type == "regular" && (lib.hasSuffix ".ts" name || lib.hasSuffix ".js" name))
        (builtins.readDir extensionsDir)
      )
    );
    # System-prompt append (the SYSTEM_APPEND mechanism): Pi reads
    # <configDir>/APPEND_SYSTEM.md and appends it verbatim to its built-in
    # system prompt. Distinct from AGENTS.md, and a project
    # .pi/APPEND_SYSTEM.md overrides this file outright (no concatenation).
    appendSystemPrompt = ./append-system-prompt.md;

    # ---- Thinking-block theme ---------------------------------------------
    # Pi renders BOTH the expanded thinking text and the collapsed
    # "Thinking..." label with the single `thinkingText` theme colour, and
    # paints the per-level thinking indicator with the `thinking*` border
    # colours (see assistant-message.js). Both default to a near-body grey,
    # so thinking is hard to tell apart from normal output. Tint them cyan so
    # thinking is unmistakable in either state.
    #
    # `mdQuote`/`mdQuoteBorder` are also cyan: the `thinking-border` extension
    # wraps expanded thinking in a markdown blockquote (the only way to get a
    # border), and blockquote content is restyled away from `thinkingText` to
    # `mdQuote`/`mdQuoteBorder`.
    #
    # The theme schema requires the full palette, so start from pi's built-in
    # dark theme (read from the installed package) and override only these
    # colours. NOTE: the read path is internal to pi's package layout; if a pi
    # update moves it, this read fails at eval time.
    builtinDarkTheme = builtins.fromJSON (builtins.readFile "${pkgs.pi-coding-agent}/lib/node_modules/pi-monorepo/dist/modes/interactive/theme/dark.json");
    thinkingThemeName = "pvdv";
    thinkingTheme =
      builtinDarkTheme
      // {
        name = thinkingThemeName;
        colors =
          builtinDarkTheme.colors
          // {
            thinkingText = "okhsl(200 70% 72%)";
            thinkingOff = "okhsl(200 25% 55%)";
            thinkingMinimal = "okhsl(200 40% 58%)";
            thinkingLow = "okhsl(200 55% 62%)";
            thinkingMedium = "okhsl(200 65% 66%)";
            thinkingHigh = "okhsl(200 75% 70%)";
            thinkingXhigh = "okhsl(200 85% 74%)";
            thinkingMax = "okhsl(200 95% 78%)";
            mdQuote = "okhsl(200 45% 70%)";
            mdQuoteBorder = "okhsl(200 70% 72%)";
          };
      };
  in {
    programs.pi-coding-agent = {
      enable = true;

      # Pi shells out to `npm` to install the `npm:` packages below. nixpkgs
      # already wraps `pi` with ripgrep and fd, so nodejs is the only extra
      # binary required.
      extraPackages = [pkgs.nodejs];

      # Settings (~/.pi/agent/settings.json)
      settings = {
        # Default startup model and thinking level. The DeepSeek API key lives
        # in ~/.pi/agent/auth.json or models.json (see note below), not here.
        defaultProvider = "deepseek";
        defaultModel = "deepseek-flash";
        defaultThinkingLevel = "low";

        # Hide thinking blocks in the transcript by default (`ctrl+t` still
        # toggles them back on at runtime). The collapsed label still uses the
        # themed `thinkingText` colour, so it stays visually distinct.
        hideThinkingBlock = true;

        # Custom cyan-tinted thinking theme, written to the themes dir below.
        theme = thinkingThemeName;

        # Extensions distributed as npm/git packages. Pi installs these into
        # <configDir>/npm using an explicit `--prefix`, so no writable global
        # npm prefix (and no npmCommand wrapper) is needed. Pin versions
        # (`npm:name@x.y.z`) for reproducible installs.
        packages = [
          # "npm:pi-web-access"
          "npm:pi-web-search"
          "npm:@juicesharp/rpiv-ask-user-question"
          "npm:billion-context"
        ];

        # Locally authored extensions, owned by Nix.
        inherit extensions;
      };

      # NOTE: `models` is intentionally left unset so Home Manager does not own
      # ~/.pi/agent/models.json. Leave it that way if you want to add providers
      # and API keys by hand: any edits you make there survive `home-manager
      # switch`. Pi reads providers from that file, and keys can either be
      # written inline or referenced as "$OPENCODE_API_KEY" etc.
    };

    # The module has no `appendSystemPrompt` option, so wire the file up by
    # hand. Like settings.json this is a Nix-store symlink, so edits made
    # in-place are lost on the next `home-manager switch`.
    home.file = {
      ".pi/agent/APPEND_SYSTEM.md".source = appendSystemPrompt;

      # Custom theme for the `theme` setting above. Pi derives the filename
      # from the theme name, hence `thinkingThemeName` in both.
      ".pi/agent/themes/${thinkingThemeName}.json".text = builtins.toJSON thinkingTheme;
    };
  };
}
