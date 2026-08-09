{...}: {
  flake.homeModules.pi-coding-agent = {pkgs, ...}: {
    # 1. Enable Pi via Home Manager
    programs.pi-coding-agent = {
      enable = true;

      # Optional: ensure extra binaries (like git, nodejs, ripgrep) are in Pi's PATH
      extraPackages = with pkgs; [
        nodejs
        ripgrep
      ];

      # Settings (~/.pi/agent/settings.json)
      settings = {
        extensions = [
          "npm:pi-model-discovery"
          "npm:pi-web-access"
        ];
      };

      # Model providers (~/.pi/agent/models.json)
      models = {
        providers = {
          opencode = {
            baseUrl = "https://opencode.ai/zen/v1";
            api = "openai-completions";
            apiKey = "sk-GZ0JCgeGRnJ76FCg6yWdl9VaQD2bYzA9lAHqREazuirSArJsBz8vGXV9OKIJaIb5";
          };
        };
      };
    };

    # 2. Environment variables for API keys
    # home.sessionVariables = {
    #   TAVILY_API_KEY = "tvly-your-tavily-api-key-here";
    #   OPENCODE_API_KEY = "your-opencode-api-key-here";
    # };
  };
}
