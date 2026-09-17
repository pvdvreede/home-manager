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
          "command(ls)"
        ];
      };
    };
  };
}
