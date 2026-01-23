# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/frigate.nix
    ./modules/ssh.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "frigate"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  users.users.pvdvreede = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "mustchangeme";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBpNpK7ljFbEzClBHjWFcY5yLwkUxs4U6uDF4YTJKQivCO2Vt+cQ5nG4Xr++QPVmQZiGytwyRgbKAp0tIRH/1pSTLmSiZDKqNUYYhmRiSHWKjPFK9L1qcHQcAReVEI6VuVC1eaZ0Dm1kzl7aS882LAjt97ceid8rRMZt79Z+TqGgIc8K0GX+79RJYZ7u7q14aqxLyHFF5NYZYEWf2yIHvxcbt5wwy+8hlqsXUzQyiCOwwnf6PRl2qOJabkTo+zEoFqawAJJDieaDny2l572YnGMg1W0zzz3fWnOP0AAymzOSP+lcp2cKPHt9aWK2EjKI+xOv67jqIKfua5lNDiq3nrRpGcGrbCrvco0/3E1SXWbGRI1XJALF3GnlenU8Fn2g8ZfIZ1RNg/N5Br2Vv1UH8is3ijPel2iYIz+NOPqgTdCyYojkdLc8sk32xDDYWkq6aaH4Sh7QifU3pBVoEy0Vep6F6r4pXrwetI+CngCQC5NITsvC4+V3OXCJZIPU8rfaJBdB4P2RQyUakHdB/5oXT0qSw78YHmqI/rVf4x0YqEeo+6bMKwZNlj1A4uNMblnI8umsVkKp5KdfJfq12+3Yao2jHlc6dRW7k9Xbx5Bh18VydR1IkD4sycBZi4hRWHW2sLZj0NwPA81OYnz0LSX8Q7T/IRs1Sd8h9MXMtG78cWBQ== pvdvreede@gmail.com"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # utils
    helix
    curl
    git
  ];

  system.autoUpgrade.enable = false;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
