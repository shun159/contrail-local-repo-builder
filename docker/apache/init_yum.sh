#!/bin/sh

# Install dependencies
yum install -y createrepo yum-utils\
  redhat-rpm-config gcc\
  libffi-devel python-devel\
  openssl-devel wget epel-release

# reposync base CentOS repositories
mkdir -p /var/www/html/{base,centosplus,extras,updates}
for repo in base centosplus extras updates; do
  echo "reposync $repo start"
  reposync -gldm \
    --repoid=$repo \
    --newest-only \
    --download-metadata \
    --download_path=/var/www/html
  echo "reposync $repo done"
done

# reposync epel repositories
mkdir -p /var/www/html/pub/epel
reposync --repoid=epel --download_path=/var/www/html/pub/epel/7/x86_64
mv /var/www/html/pub/epel/7/x86_64/epel/Packages/ /var/www/html/pub/epel/7/x86_64/
rm -rf /var/www/html/pub/epel/7/x86_64/epel/

# reposync docker.com repositories
echo "reposync docker start"
mkdir -p /var/www/html/linux/centos/
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
reposync --repoid=docker-ce-stable --download_path=/var/www/html/linux/centos/
echo "reposync docker done"


# Finalize
cd /
createrepo /var/www/html
