#!/bin/bash
# Script de instalación para Jenkins + Apache (Ubuntu 20.04/22.04)
# -------------------------------------------------------------------
# Configura Jenkins en el puerto 8080 y Apache como proxy inverso (puerto 80)
# Autor: Tu Nombre
# -------------------------------------------------------------------

# 1. Actualizar sistema e instalar dependencias
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y openjdk-11-jdk wget

# 2. Instalar Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# 3. Instalar Apache y configurar proxy inverso
sudo apt-get install -y apache2
sudo a2enmod proxy proxy_http

# Crear configuración de virtual host para Jenkins
sudo tee /etc/apache2/sites-available/jenkins.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName tu-dominio.com  # Cambiar por tu IP o dominio real

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/ nocanon
    ProxyPassReverse / http://localhost:8080/
    ProxyRequests Off

    <Proxy http://localhost:8080/*>
        Order deny,allow
        Allow from all
    </Proxy>

    ErrorLog \${APACHE_LOG_DIR}/jenkins_error.log
    CustomLog \${APACHE_LOG_DIR}/jenkins_access.log combined
</VirtualHost>
EOF

# 4. Habilitar configuración y reiniciar servicios
sudo a2dissite 000-default
sudo a2ensite jenkins
sudo systemctl restart apache2
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 5. Mostrar información de acceso
echo "-----------------------------------------------------------"
echo "          JENKINS INSTALADO CORRECTAMENTE"
echo "-----------------------------------------------------------"
echo " * URL de acceso: http://$(curl -s ifconfig.me)"  # Reemplazar por IP fija en producción
echo " * Puerto alternativo: http://$(curl -s ifconfig.me):8080"
echo " * Contraseña inicial: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo "-----------------------------------------------------------"
