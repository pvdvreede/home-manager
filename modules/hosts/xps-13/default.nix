{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.xps-13 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.nix
      self.nixosModules.fish
      self.nixosModules.niri
      self.nixosModules.xps-13
      self.nixosModules.laptop
      self.nixosModules.docker
      self.nixosModules.greet
    ];
  };

  flake.nixosModules.xps-13 = {pkgs, ...}: {
    nixpkgs.hostPlatform = "x86_64-linux";

    imports = [
      # Include the results of the hardware scan.
      ./_hardware-configuration.nix
    ];
    environment.systemPackages = [
      pkgs.wget
      pkgs.coreutils
      pkgs.google-chrome
    ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.initrd.luks.devices."luks-124d9bac-d0d1-43cc-a080-049599cc4a28".device = "/dev/disk/by-uuid/124d9bac-d0d1-43cc-a080-049599cc4a28";
    networking.hostName = "xps-13"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Australia/Melbourne";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_AU.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."pvdvreede" = {
      isNormalUser = true;
      description = "pvdvreede";
      extraGroups = ["networkmanager" "wheel"];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    home-manager.users.pvdvreede = {
      home.username = "pvdvreede";
      home.stateVersion = "24.11";

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
        self.homeModules.kitty
        self.homeModules.opencode
        self.homeModules.nix
        self.homeModules.devenv
        self.homeModules.niri
        self.homeModules.noctalia
      ];
    };

    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.useGlobalPkgs = true;
    system.stateVersion = "26.05";
  };
}
