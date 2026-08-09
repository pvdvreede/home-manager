{
  provision = [
    {
      mode = "system";
      script = ''
        #!/bin/bash
        set -e

        # Install extra kernel modules if not present
        apt-get update
        apt-get install -y linux-modules-extra-$(uname -r) || true

        # Load required modules for Kubernetes networking
        modprobe bridge || true
        modprobe br_netfilter || true
        modprobe overlay || true

        # Make them persist across reboots
        cat <<EOF > /etc/modules-load.d/k8s.conf
        bridge
        br_netfilter
        overlay
        EOF

        # Required sysctl settings for Kubernetes
        cat <<EOF > /etc/sysctl.d/k8s.conf
        net.bridge.bridge-nf-call-iptables  = 1
        net.bridge.bridge-nf-call-ip6tables = 1
        net.ipv4.ip_forward                 = 1
        EOF

        sysctl --system
      '';
    }
    {
      mode = "system";
      script = ''
        #!/bin/bash
        set -e
        apt-get update
        apt-get install -y podman
      '';
    }
  ];
}
