#!/bin/sh

PLATFORM=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Install Docker
if [ "$PLATFORM" = "\"CentOS Linux\"" ]; then
  openssl req -x509 -nodes -days 3650\
              -newkey rsa:2048\
              -keyout /etc/pki/tls/certs/apache.key \
              -out /etc/pki/tls/certs/apache.crt \
              -subj "/CN=$(hostname --fqdn)"
  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io
  mkdir -p /usr/lib/systemd/system/docker.service.d
  cat <<'EOS' > /usr/lib/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H fd:// -H tcp://0.0.0.0:2375
EOS
  mkdir -p /etc/docker
  if [ ! -f "/etc/docker/daemon.json" ]; then
    echo "{ \"insecure-registries\": [\"$(hostname):5000\"] }" > /etc/docker/daemon.json
  fi
  systemctl daemon-reload
  systemctl restart docker
  systemctl enable docker
  curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

docker-compose up
