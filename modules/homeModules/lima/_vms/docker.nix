{
  provision = [
    {
      mode = "system";
      script = ''
        #!/bin/bash
        set -e

        # Install extra kernel modules if not present
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
        set -eux -o pipefail
        command -v docker >/dev/null 2>&1 && exit 0
        export DEBIAN_FRONTEND=noninteractive
        curl -fsSL https://get.docker.com | sh
      '';
    }
    {
      mode = "yq";
      path = "/etc/systemd/system/docker.socket.d/override.conf";
      format = "ini";
      expression = ".Socket.SocketUser=\"{{.User}}\"";
    }
    {
      mode = "yq";
      path = "/etc/docker/daemon.json";
      expression = ''
        .features.cdi = true
      '';
    }
    {
      mode = "system";
      script = ''
        #!/bin/bash
        set -eux -o pipefail
        docker run --privileged --rm tonistiigi/binfmt --install all || true
      '';
    }
  ];

  probes = [
    {
      script = ''
        #!/bin/bash
        set -eux -o pipefail
        if ! timeout 30s bash -c "until docker info >/dev/null 2>&1; do sleep 3; done"; then
          echo >&2 "Docker daemon is not ready"
          exit 1
        fi
      '';
      hint = "Docker daemon not ready yet — check `limactl shell docker sudo journalctl -u docker`";
    }
  ];

  portForwards = [
    {
      guestSocket = "/var/run/docker.sock";
      hostSocket = "{{.Dir}}/sock/docker.sock";
    }
  ];
}
