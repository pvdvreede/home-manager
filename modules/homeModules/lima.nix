{...}: {
  flake.homeModules.lima = {
    pkgs,
    lib,
    ...
  }: let
    limaDockerConfig = {
      vmType = "vz";
      arch = "aarch64";

      # vmOpts.vz.rosetta = true;

      containerd = {
        system = false;
        user = false;
      };

      images = [
        {
          location = "https://cloud-images.ubuntu.com/releases/noble/release-20260225/ubuntu-24.04-server-cloudimg-arm64.img";
          arch = "aarch64";
          digest = "sha256:99e1d482b958e6bfd0183a4c48ce6dc334e09a3e29a4560f6f5ff85593d09d1d";
        }
      ];

      cpus = 4;
      memory = "16GiB";
      disk = "120GiB";

      mounts = [
        {
          location = "~";
          writable = true;
        }
        {
          location = "/tmp/lima";
          writable = true;
        }
      ];

      mountType = "virtiofs";

      networks = [
        {vzNAT = true;}
      ];

      ssh = {
        localPort = 0;
        loadDotSSHPubKeys = true;
      };

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
    };

    limaDockerYaml = (pkgs.formats.yaml {}).generate "lima-docker.yaml" limaDockerConfig;
  in {
    home.packages = with pkgs; [
      lima
      docker
      docker-compose
      vcluster
      k9s
      kubectl
    ];

    home.sessionVariables = {
      DOCKER_HOST = "unix://$HOME/.lima/docker/sock/docker.sock";
    };

    home.file.".lima/docker/lima.yaml".source = limaDockerYaml;
  };
}
