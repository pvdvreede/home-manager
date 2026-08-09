{...}: {
  flake.nixosModules.pveContainer = {
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];

    boot.isContainer = true;
    boot.loader.initScript.enable = true;

    time.timeZone = "Australia/Melbourne";

    systemd.suppressedSystemUnits = [
      "dev-mqueue.mount"
      "sys-kernel-debug.mount"
      "sys-fs-fuse-connections.mount"
    ];

    system.activationScripts.fix-sbin-init = {
      deps = ["binsh"];
      text = ''
        if [ -L /sbin/init ]; then
          echo "Init is already a symlink, skipping."
        else
          echo "Converting static /sbin/init to symlink..."
          rm -f /sbin/init
          mkdir -p /sbin
          ln -s /nix/var/nix/profiles/system/init /sbin/init
        fi
      '';
    };

    services.openssh = {
      enable = true;
      settings = {
        AllowUsers = null;
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
      openFirewall = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };

    users.mutableUsers = true;
  };
}
