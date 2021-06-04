#!/bin/sh

PLATFORM=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
HOSTNAME=$(hostnamectl status | awk '{ if($0 ~ /Static host/) print C$3  }')
VHOSTS="dl.fedoraproject.org pypi.python.org download.docker.com apache"

# Install Docker
for vhost in $VHOSTS; do
  cname=$vhost
  if [ "$vhost" = "apache" ]; then cname="${HOSTNAME}"; fi
  openssl genrsa -des3 -passout pass:juniper -out "/etc/pki/tls/certs/${vhost}.pass.key" 2048
  openssl rsa -passin pass:juniper -in "/etc/pki/tls/certs/${vhost}.pass.key" -out "/etc/pki/tls/certs/${vhost}.key"
  rm "/etc/pki/tls/certs/${vhost}.pass.key"
  openssl req -new\
              -out "/etc/pki/tls/certs/${vhost}.csr"\
              -key "/etc/pki/tls/certs/${vhost}.key"\
              -subj "/CN=${cname}"

  openssl x509 -req\
              -days 3650\
              -in "/etc/pki/tls/certs/${vhost}.csr"\
              -signkey "/etc/pki/tls/certs/${vhost}.key"\
              -out "/etc/pki/tls/certs/${vhost}.crt"
done
