#!/bin/bash

# Script para instalar la versión específica de Artifactory 7.90.15 en Debian/Ubuntu.
# ¡ADVERTENCIA! Esta versión es antigua y puede tener vulnerabilidades de seguridad.
# Usar bajo tu propia responsabilidad.

# URL del paquete .deb para la versión 7.90.15
# Esta URL apunta a un archivo histórico, por lo que podría dejar de funcionar en el futuro.
ARTIFACTORY_DEB_URL="https://releases.jfrog.io/artifactory/artifactory-pro-debs/pool/jfrog-artifactory-pro/jfrog-artifactory-pro-7.90.15.deb"

echo "--- Inicio del script de instalación de Artifactory 7.90.15 ---"

# --- Paso 1: Actualizar paquetes del sistema ---
echo "Paso 1: Actualizando los paquetes del sistema..."
sudo apt update -y
sudo apt upgrade -y
echo "Paquetes del sistema actualizados."
echo "---------------------------------------------------------"

# --- Paso 2: Instalar Java 11 ---
# Artifactory 7.90.15 requiere Java 11, aunque lo incluye, se instala como dependencia del sistema.
echo "Paso 2: Instalando Java 11 y otras dependencias..."
sudo apt install -y openjdk-11-jre-headless curl wget
echo "Dependencias instaladas."
echo "---------------------------------------------------------"

# --- Paso 3: Descargar e instalar Artifactory ---
echo "Paso 3: Descargando Artifactory 7.90.15..."
wget -q "$ARTIFACTORY_DEB_URL" -O artifactory.deb

if [ ! -f artifactory.deb ]; then
    echo "Error: Fallo en la descarga del paquete de Artifactory. El URL puede haber cambiado."
    echo "Por favor, verifica el URL en https://releases.jfrog.io/artifactory/bintray-archive/"
    exit 1
fi

echo "Instalando Artifactory desde el paquete .deb..."
sudo dpkg -i artifactory.deb
sudo apt --fix-broken install -y
rm artifactory.deb
echo "Artifactory 7.90.15 instalado."
echo "---------------------------------------------------------"

# --- Paso 4: Iniciar y habilitar el servicio ---
echo "Paso 4: Iniciando y habilitando el servicio Artifactory..."
sudo systemctl start artifactory
sudo systemctl enable artifactory
echo "---------------------------------------------------------"

# --- Paso 5: Mostrar estado del servicio ---
echo "Paso 5: Verificando el estado del servicio..."
if systemctl is-active --quiet artifactory; then
    echo "Artifactory se ha instalado y está corriendo."
else
    echo "Error: Fallo al instalar/iniciar Artifactory. Revisa los logs en /opt/jfrog/artifactory/var/log."
    exit 1
fi
echo "---------------------------------------------------------"

echo "--- Instalación de Artifactory 7.90.15 completada ---"
echo "Puedes acceder a la interfaz web de Artifactory en el puerto 8082."
echo "URL: http://DIRECCION_IP_DE_TU_SERVIDOR:8082"
echo "La contraseña de administrador inicial se encuentra en /opt/jfrog/artifactory/var/etc/security/artifactory.key."
echo "Para el primer inicio de sesión, el usuario por defecto es 'admin'."