{
  inputs,
  self,
  ...
}: {
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.home-manager.darwinModules.home-manager
      self.darwinModules.workbook
    ];
  };

  flake.darwinModules.workbook = {pkgs, ...}: {
    system.stateVersion = 6;
    environment.shells = [pkgs.fish];
    programs.fish.enable = true;
    users.knownUsers = ["paul.vandevreede"];
    system.primaryUser = "paul.vandevreede";
    nixpkgs.hostPlatform = "aarch64-darwin";

    nix.settings.trusted-users = ["root" "paul.vandevreede"];
    nix.settings.ssl-cert-file = "/Users/paul.vandevreede/.all-ca-bundle.pem";
    environment.variables = {
      SSL_CERT_FILE = "/Users/paul.vandevreede/.all-ca-bundle.pem";
      NIX_SSL_CERT_FILE = "/Users/paul.vandevreede/.all-ca-bundle.pem";
    };
    nixpkgs.config.allowUnfree = true;

    system.defaults = {
      NSGlobalDomain = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        AppleICUForce24HourTime = true;
        "com.apple.swipescrolldirection" = false;
      };

      dock.autohide = true;
      dock.mru-spaces = false;
      dock.autohide-delay = 0.2;
      dock.wvous-tl-corner = 2; # mission control
      # other corners disabled
      dock.wvous-br-corner = 1;
      dock.wvous-bl-corner = 1;
      dock.wvous-tr-corner = 1;
      finder._FXShowPosixPathInTitle = true;
      finder.AppleShowAllExtensions = true;
      finder.AppleShowAllFiles = true;
      finder.CreateDesktop = false;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;

      screensaver.askForPassword = true;
      screensaver.askForPasswordDelay = 60;

      WindowManager.EnableTiledWindowMargins = true;
      WindowManager.AutoHide = true;
      WindowManager.StandardHideWidgets = true;
      WindowManager.HideDesktop = true;
      WindowManager.EnableTilingOptionAccelerator = true;

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 0;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
      };
    };

    system.startup.chime = false;

    homebrew.enable = true;
    homebrew.onActivation.cleanup = "none";
    homebrew.onActivation.autoUpdate = true;
    homebrew.onActivation.upgrade = true;
    homebrew.casks = [
      "zed"
      "herdr-app"
      "t3-code"
      "wezterm@nightly"
    ];

    users.users."paul.vandevreede" = {
      name = "paul.vandevreede";
      home = "/Users/paul.vandevreede";
      uid = 502;
      shell = pkgs.fish;
      isHidden = false;
    };

    home-manager.users."paul.vandevreede" = {
      home.username = "paul.vandevreede";
      home.stateVersion = "24.11";
      home.homeDirectory = "/Users/paul.vandevreede";

      home.packages = [pkgs.devbox];

      targets.darwin.copyApps.enableChecks = false;
      imports = [
        self.homeModules.fish
        self.homeModules.helix
        self.homeModules.git
        self.homeModules.jujutsu
        self.homeModules.lazygit
        self.homeModules.zoxide
        self.homeModules.eza
        self.homeModules.gh
        self.homeModules.gh-dash
        self.homeModules.ghq
        self.homeModules.wt
        self.homeModules.starship
        self.homeModules.kitty
        self.homeModules.lima
        self.homeModules.nix
        self.homeModules.devenv
        self.homeModules.direnv
        self.homeModules.zed-editor
        self.homeModules.pi-coding-agent
        self.homeModules.awscli
        self.homeModules.granted
        self.homeModules.herdr-app
        self.homeModules.t3-code
        self.homeModules.wezterm
        self.homeModules.delta
      ];

      programs.pi-coding-agent.settings = {
        defaultProvider = "anthropic";
        defaultModel = "claude-opus-5-5";
        defaultThinkingLevel = "medium";
      };

      # Read-only store symlink: /mcp exposure and enable toggles cannot be
      # saved here. OAuth tokens live in ~/.pi/agent/mcp-auth.json.
      home.file.".pi/agent/mcp.json".text = builtins.toJSON {
        mcpServers.datadog = {
          url = "https://mcp.datadoghq.com/v1/mcp";
          description = "Query Datadog logs, metrics, traces, monitors, dashboards and incidents";
        };
      };
    };

    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.useGlobalPkgs = true;
  };
}
