#!/bin/bash

# Este script instala la versión específica y antigua de Jenkins 2.164.3 en RHEL/CentOS.
# ¡ADVERTENCIA! Esta versión no tiene soporte ni actualizaciones de seguridad.
# Usar bajo tu propia responsabilidad.

echo "--- Inicio del script de instalación de Jenkins 2.164.3 en RHEL ---"

# --- Paso 1: Actualizar los paquetes del sistema ---
echo "Paso 1: Actualizando los paquetes del sistema..."
sudo yum update -y
echo "Paquetes del sistema actualizados."

# --- Paso 2: Instalar Java 8 ---
# Jenkins 2.164.3 requiere Java 8.
echo "Paso 2: Instalando Java 8 (OpenJDK 8)..."
sudo yum install -y java-1.8.0-openjdk

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
echo "Paso 3: Descargando e instalando Jenkins 2.164.3..."
JENKINS_RPM_URL="https://archives.jenkins.io/redhat-stable/jenkins-2.164.3-1.1.noarch.rpm"
sudo yum install -y wget
wget "$JENKINS_RPM_URL" -O jenkins.rpm
sudo rpm -ivh jenkins.rpm
rm jenkins.rpm
echo "Jenkins 2.164.3 instalado."

# --- Paso 4: Iniciar y habilitar el servicio de Jenkins ---
echo "Paso 4: Iniciando y habilitando el servicio de Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

if systemctl is-active --quiet jenkins; then
    echo "Jenkins 2.164.3 se ha instalado y está corriendo."
else
    echo "Error: Fallo al instalar/iniciar Jenkins. Revisa los logs con:"
    echo "sudo journalctl -u jenkins -xe"
    exit 1
fi
echo "Jenkins 2.164.3 en ejecución."

# --- Paso 5: Ajustar el Firewall (firewalld) ---
echo "Paso 5: Ajustando el Firewall (firewalld) si está activo..."
if command -v firewall-cmd &> /dev/null; then
    echo "Firewalld detectado. Abriendo el puerto 8080 para Jenkins..."
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload
    echo "Puerto 8080 abierto en firewalld."
else
    echo "Firewalld no detectado o no activo. Si tienes un firewall, asegúrate de que el puerto 8080 esté abierto."
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

echo "--- Instalación de Jenkins 2.164.3 en RHEL completada ---"
echo "Accede a Jenkins en tu navegador web en:"
echo "http://$(hostname -I | awk '{print $1}'):8080"
echo "Usa la contraseña mostrada arriba para desbloquearlo."
echo "Sigue las instrucciones en pantalla para instalar plugins y crear tu primer usuario."