#!/bin/bash

# Este script instala Jenkins en un servidor Linux (Debian/Ubuntu).
# Asegúrate de tener privilegios de sudo para ejecutarlo.

echo "--- Inicio del script de instalación de Jenkins para Debian/Ubuntu ---"

# --- Paso 1: Actualizar los paquetes del sistema ---
echo "Paso 1: Actualizando los paquetes del sistema..."
sudo apt update -y
sudo apt upgrade -y
echo "Paquetes del sistema actualizados."

# --- Paso 2: Instalar Java (OpenJDK 11 JRE) ---
# Jenkins requiere Java para funcionar. Se recomienda OpenJDK.
echo "Paso 2: Instalando Java (OpenJDK 11 JRE)..."
sudo apt install openjdk-17-jre -y

# Verifica si Java se instaló correctamente
if java -version &> /dev/null; then
    echo "Java instalado correctamente:"
    java -version
else
    echo "Error: Fallo al instalar Java. Saliendo."
    exit 1
fi
echo "Java instalado."

# --- Paso 3: Añadir el repositorio de Jenkins ---
echo "Paso 3: Añadiendo el repositorio de Jenkins..."
# Descargar la clave GPG de Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
# Añadir el repositorio de Jenkins a la lista de fuentes APT
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
echo "Repositorio de Jenkins añadido y lista de paquetes actualizada."

# --- Paso 4: Instalar Jenkins ---
echo "Paso 4: Instalando Jenkins..."
sudo apt install jenkins -y

if systemctl is-active --quiet jenkins; then
    echo "Jenkins ya estaba corriendo o se inició automáticamente."
else
    echo "Iniciando el servicio Jenkins..."
    sudo systemctl start jenkins
    echo "Habilitando Jenkins para que se inicie en el arranque del sistema..."
    sudo systemctl enable jenkins
fi

if systemctl is-active --quiet jenkins; then
    echo "Jenkins se ha instalado y está corriendo."
else
    echo "Error: Fallo al instalar/iniciar Jenkins. Por favor, revisa los logs."
    exit 1
fi
echo "Jenkins instalado y en ejecución."

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

echo "--- Instalación de Jenkins completada ---"
echo "Ahora puedes acceder a Jenkins en tu navegador web en:"
echo "http://DIRECCION_IP_DE_TU_SERVIDOR:8080"
echo "¡No olvides reemplazar DIRECCION_IP_DE_TU_SERVIDOR con la IP real de tu servidor!"
echo "Una vez que accedas, usa la contraseña mostrada arriba para desbloquearlo."
echo "Sigue las instrucciones en pantalla para instalar los plugins recomendados y crear tu primer usuario administrador."