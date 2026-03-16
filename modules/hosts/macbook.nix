{
  inputs,
  self,
  ...
}: {
  flake.darwinConfigurations.macbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.home-manager.darwinModules.home-manager
      self.darwinModules.macbook
    ];
  };

  flake.darwinModules.macbook = {pkgs, ...}: {
    system.stateVersion = 6;
    environment.shells = [pkgs.fish];
    system.primaryUser = "pvdvreede";
    nixpkgs.hostPlatform = "aarch64-darwin";
    nix.settings.experimental-features = "nix-command flakes";
    nix.package = pkgs.nix;

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
    homebrew.casks = [
      "google-chrome"
      "kitty"
      "tailscale-app"
      "cmux"
    ];

    users.users.pvdvreede = {
      name = "pvdvreede";
      home = "/Users/pvdvreede";
    };

    home-manager.users.pvdvreede = {
      home.username = "pvdvreede";
      home.stateVersion = "24.11";
      home.homeDirectory = "/Users/pvdvreede";

      targets.darwin.copyApps.enableChecks = false;
      imports = [
        self.homeModules.fish
        self.homeModules.helix
        self.homeModules.git
        self.homeModules.jujutsu
        self.homeModules.zoxide
        self.homeModules.eza
        self.homeModules.gh
        self.homeModules.ghq
        self.homeModules.starship
        self.homeModules.ghostty
      ];
    };

    nix.settings.trusted-users = ["root" "pvdvreede"];

    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.useGlobalPkgs = true;
  };
}
