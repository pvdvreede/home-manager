{...}: {
  flake.homeModules.antigravity = {...}: {
    programs.antigravity-cli = {
      enable = true;
      settings = {
        context.filename = ["AGENTS.md" "CLAUDE.md" "GEMINI.md" "AGENT.md"];
      };
      permissions = {
        allow = [
          "command(git)"
          "command(jj)"
          "command(nix)"
          "command(python)"
          "command(python3)"
          "command(ls)"
          "command(ll)"
          "command(find)"
          "command(devenv)"
          "command(tree)"
          "command(mkdir)"
          "command(yq)"
          "command(jq)"
          "command(curl)"
          "command(cat)"
          "command(tail)"
          "command(head)"
          "command(cp)"
        ];
      };
    };
  };
}
