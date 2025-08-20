#!/bin/bash

# Este script instala Docker en un sistema Linux Red Hat.

echo "--- Inicio del script de instalación de Docker ---"

# --- Paso 1: Actualizar los paquetes del sistema ---
echo "Paso 1: Actualizando los paquetes del sistema..."
sudo yum update -y
echo "Paquetes del sistema actualizados."
echo "---------------------------------------------------"

# --- Paso 2: Instalar los paquetes de repositorio de yum-utils ---
echo "Paso 2: Instalando yum-utils y dependencias..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
echo "Dependencias instaladas."
echo "---------------------------------------------------"

# --- Paso 3: Añadir el repositorio oficial de Docker ---
echo "Paso 3: Añadiendo el repositorio de Docker..."
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
echo "Repositorio de Docker añadido."
echo "---------------------------------------------------"

# --- Paso 4: Instalar la última versión de Docker Engine ---
echo "Paso 4: Instalando Docker Engine..."
sudo yum install -y docker-ce docker-ce-cli containerd.io
echo "Docker Engine instalado."
echo "---------------------------------------------------"

# --- Paso 5: Iniciar y habilitar el servicio Docker ---
echo "Paso 5: Iniciando y habilitando el servicio Docker..."
sudo systemctl start docker
sudo systemctl enable docker
echo "Servicio Docker iniciado y habilitado."
echo "---------------------------------------------------"

# --- Paso 6: Añadir el usuario actual al grupo 'docker' ---
echo "Paso 6: Añadiendo el usuario actual al grupo 'docker'..."
sudo usermod -aG docker $USER
echo "Usuario '$USER' añadido al grupo 'docker'."
echo "Para que el cambio surta efecto, cierra la sesión y vuelve a iniciarla."
echo "---------------------------------------------------"

# --- Paso 7: Instalar y lanzar el registro de Docker (Docker Registry) ---
echo "Paso 7: Lanzando el registro de Docker en el puerto 5000..."
# El registro se lanza como un contenedor de Docker
docker run -d -p 5000:5000 --restart=always --name registry registry:2
echo "Registro de Docker lanzado y configurado para iniciarse automáticamente."
echo "---------------------------------------------------"

echo "--- Instalación de Docker y Registro completada ---"