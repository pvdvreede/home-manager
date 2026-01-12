{...}: {
  programs.gemini-cli = {
    enable = true;

    settings = {
      context.fileName = ["AGENTS.md" "CONTEXT.md" "GEMINI.md"];
      context.includeDirectories = ["~/.config"];
      tools.autoAccept = true;
      tools.allowed = [
        "run_shell_command(git)"
        "run_shell_command(devcontainer)"
      ];
      ide = {
        enabled = true;
      };
      privacy = {
        usageStatisticsEnabled = false;
      };
      security = {
        auth = {
          selectedType = "oauth-personal";
        };
      };
      general = {
        preferredEditor = "hx";
        previewFeatures = true;
        retryFetchErrors = true;
      };
    };
  };
}
