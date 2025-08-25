#!/bin/bash
set -e

sudo lvextend -L +2G /dev/mapper/rootvg-homelv
sudo xfs_growfs /home
sudo lvextend -L +8G /dev/mapper/rootvg-rootlv
sudo xfs_growfs /


# PostgreSQL Installation and Configuration
# Define las variables
DB_USER="artifactory_user"
DB_NAME="artifactory_db"
DB_PASSWORD="your_secure_password" # ¡Cambia esta contraseña por una segura!
PG_VERSION=15 # Versión de PostgreSQL a instalar

# Instalar el repositorio de PostgreSQL
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Deshabilitar el módulo de PostgreSQL por defecto para evitar conflictos
sudo dnf -qy module disable postgresql

# Instalar el cliente y servidor de PostgreSQL 15
sudo dnf install -y postgresql${PG_VERSION}-server

# Inicializar la base de datos y habilitar el servicio
sudo /usr/pgsql-${PG_VERSION}/bin/postgresql-${PG_VERSION}-setup initdb
sudo systemctl enable postgresql-${PG_VERSION}
sudo systemctl start postgresql-${PG_VERSION}

# Crear el usuario y la base de datos
sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"
sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} WITH OWNER ${DB_USER};"

# Configurar la autenticación de host para permitir conexiones remotas
# (Importante: La configuración `listen_addresses` por defecto es 'localhost')
echo "host all ${DB_USER} 0.0.0.0/0 scram-sha-256" | sudo tee -a /var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf > /dev/null

# Reiniciar PostgreSQL para aplicar la configuración
sudo systemctl restart postgresql-${PG_VERSION}

echo "PostgreSQL 15 instalado y configurado. Base de datos '${DB_NAME}' y usuario '${DB_USER}' creados."



# Instalar Artifactory 
# Variables
ARTIFACTORY_VERSION=7.90.15
XRAY_VERSION=3.88.12
echo "Instalando Artifactory version ${ARTIFACTORY_VERSION} y Xray version ${XRAY_VERSION}"
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
echo "creado en var/opt/jfrog"
# wget -q https://releases.jfrog.io/artifactory/artifactory-pro-rpms/jfrog-artifactory-pro/jfrog-artifactory-pro-${ARTIFACTORY_VERSION}.rpm
# sudo yum install -y jfrog-artifactory-pro-${ARTIFACTORY_VERSION}.rpm

# sudo lvextend -L +8G /dev/mapper/rootvg-varlv
# sudo xfs_growfs /var

sudo curl -g -L -O -J https://releases.jfrog.io/artifactory/artifactory-rpms/jfrog-artifactory-oss/jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.rpm
echo "Descargado Artifactory"
sudo yum install -y jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.rpm
echo "Instalado Artifactory"
# sudo netstat -tulpn | grep 8081
sudo firewall-cmd --zone=public --add-port=8081/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --add-port=8082/tcp --permanent
sudo firewall-cmd --reload
echo "Puerto 8081 abierto en el firewall"

# Descargar Xray
# wget -q https://releases.jfrog.io/artifactory/jfrog-xray/xray-rpm/${XRAY_VERSION}/jfrog-xray-${XRAY_VERSION}-rpm.tar.gz
# tar -xvf jfrog-xray-${XRAY_VERSION}-rpm.tar.gz
# cd jfrog-xray-${XRAY_VERSION}-rpm
# sudo yum install -y jfrog-xray-${XRAY_VERSION}.rpm

# Configurar Artifactory para usar PostgreSQL
sudo sed -i "/database:/a\
  type: postgresql
  driver: org.postgresql.Driver
  url: jdbc:postgresql://localhost:5432/artifactory_db
  username: artifactory_user
  password: your_secure_password"

echo "Configuración de PostgreSQL agregada a CONFIG_FILE"

# Habilitar servicios
# sudo systemctl enable artifactory 
# sudo systemctl enable xray

# Iniciar servicios
sudo systemctl start artifactory
echo "Artifactory ${ARTIFACTORY_VERSION} instalado y en ejecución."
# sudo systemctl start xray
#sudo tail -50 /opt/jfrog/artifactory/var/log/artifactory-service.log

# Usuario: admin

# Contraseña: password