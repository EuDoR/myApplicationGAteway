#!/bin/bash
set -e

# Variables
ARTIFACTORY_VERSION=7.90.15
XRAY_VERSION=3.88.12

# Requisitos previos
sudo yum install -y curl wget tar

# Crear usuario jfrog
id -u jfrog &>/dev/null || sudo useradd -m -s /bin/bash jfrog

# Directorios
sudo mkdir -p /opt/jfrog
sudo chown -R jfrog:jfrog /opt/jfrog

#asignar memoria
sudo mkdir -p /var/opt/jfrog
sudo ln -s /var/opt/jfrog /opt/jfrog

# Descargar Artifactory
cd /var/opt/jfrog
wget -q https://releases.jfrog.io/artifactory/artifactory-pro-rpms/jfrog-artifactory-pro/jfrog-artifactory-pro-${ARTIFACTORY_VERSION}.rpm
sudo yum install -y jfrog-artifactory-pro-${ARTIFACTORY_VERSION}.rpm

# sudo lvextend -L +30G /dev/mapper/rootvg-varlv
# sudo xfs_growfs /var

#curl -g -L -O -J 'https://releases.jfrog.io/artifactory/artifactory-rpms/jfrog-artifactory-oss/jfrog-artifactory-oss-[RELEASE].rpm'
#sudo yum install -y jfrog-artifactory-oss-7.90.15.rpm
# sudo netstat -tulpn | grep 8081
# sudo firewall-cmd --zone=public --add-port=8081/tcp --permanent
# sudo firewall-cmd --reload


# Descargar Xray
# wget -q https://releases.jfrog.io/artifactory/jfrog-xray/xray-rpm/${XRAY_VERSION}/jfrog-xray-${XRAY_VERSION}-rpm.tar.gz
# tar -xvf jfrog-xray-${XRAY_VERSION}-rpm.tar.gz
# cd jfrog-xray-${XRAY_VERSION}-rpm
# sudo yum install -y jfrog-xray-${XRAY_VERSION}.rpm

# Habilitar servicios
sudo systemctl enable artifactory 
# sudo systemctl enable xray

# Iniciar servicios
sudo systemctl start artifactory
# sudo systemctl start xray
