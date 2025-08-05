#!/bin/bash

# Este script instala la versión específica y antigua de Jenkins 2.164.3 en Debian/Ubuntu.
# ¡ADVERTENCIA! Esta versión no tiene soporte ni actualizaciones de seguridad.
# Usar bajo tu propia responsabilidad.

echo "--- Inicio del script de instalación de Jenkins 2.164.3 ---"

# --- Paso 1: Actualizar los paquetes del sistema ---
echo "Paso 1: Actualizando los paquetes del sistema..."
sudo apt update -y
sudo apt upgrade -y
echo "Paquetes del sistema actualizados."

# --- Paso 2: Instalar Java 8 ---
# Jenkins 2.164.3 requiere Java 8.
echo "Paso 2: Instalando Java 8 (OpenJDK 8 JRE)..."
sudo apt install openjdk-8-jre -y

# Verifica si Java se instaló correctamente
if java -version &> /dev/null; then
    echo "Java instalado correctamente:"
    java -version
else
    echo "Error: Fallo al instalar Java 8. Saliendo."
    exit 1
fi
echo "Java 8 instalado."

# --- Paso 3: Descargar e instalar Jenkins 2.164.3 ---
# Descargamos el paquete .deb directamente del archivo histórico de Jenkins.
echo "Paso 3: Descargando e instalando Jenkins 2.164.3..."
JENKINS_DEB_URL="https://archives.jenkins.io/debian-stable/jenkins_2.164.3_all.deb"
wget "$JENKINS_DEB_URL" -O jenkins.deb
sudo dpkg -i jenkins.deb
sudo apt --fix-broken install -y
rm jenkins.deb
echo "Jenkins 2.164.3 instalado."

# --- Paso 4: Iniciar y habilitar el servicio de Jenkins ---
echo "Paso 4: Iniciando y habilitando el servicio de Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

if systemctl is-active --quiet jenkins; then
    echo "Jenkins 2.164.3 se ha instalado y está corriendo."
else
    echo "Error: Fallo al instalar/iniciar Jenkins. Por favor, revisa los logs."
    exit 1
fi
echo "Jenkins 2.164.3 en ejecución."

# --- Paso 5: Ajustar el Firewall (UFW) ---
echo "Paso 5: Ajustando el Firewall (UFW) si está activo..."
if command -v ufw &> /dev/null; then
    echo "UFW detectado. Abriendo el puerto 8080 para Jenkins..."
    sudo ufw allow 8080/tcp
    sudo ufw reload
    echo "Puerto 8080 abierto en UFW."
else
    echo "UFW no detectado o no activo. Si tienes un firewall, asegúrate de que el puerto 8080 esté abierto."
fi

# --- Paso 6: Mostrar la contraseña inicial de Jenkins ---
echo "Paso 6: Mostrando la contraseña inicial de Jenkins..."
echo "---------------------------------------------------------"
echo "Para desbloquear Jenkins, necesitarás la contraseña inicial."
echo "La contraseña está en este archivo. Cópiala y pégala en la interfaz web de Jenkins."
echo "Ruta del archivo de contraseña: /var/lib/jenkins/secrets/initialAdminPassword"
echo "---------------------------------------------------------"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "---------------------------------------------------------"

echo "--- Instalación de Jenkins 2.164.3 completada ---"
echo "Ahora puedes acceder a Jenkins en tu navegador web en:"
echo "http://DIRECCION_IP_DE_TU_SERVIDOR:8080"
echo "¡No olvides reemplazar DIRECCION_IP_DE_TU_SERVIDOR con la IP real de tu servidor!"
echo "Una vez que accedas, usa la contraseña mostrada arriba para desbloquearlo."
echo "Sigue las instrucciones en pantalla para instalar los plugins y crear tu primer usuario."