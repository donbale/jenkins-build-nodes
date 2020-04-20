#!/bin/bash

# Install additional packages not available during OS installation
yum -y install \
    epel-release.noarch \
    gcc \
    yum-utils

# Install docker-compose if it doesn't already exist on the base image
if [ ! -e "/usr/bin/docker-compose" ]; then
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y docker-ce

	systemctl start docker
	systemctl enable docker
	usermod -aG docker admin

	curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Pull latest version
docker-compose -f /etc/sysconfig/ANN.yml pull

# Ensure scripts are executable; permissions don't seem to get preserved on Windows
chmod a+rx /bin/startANN /bin/stopANN /bin/restartANN /bin/statusANN /bin/configureANN

startANN