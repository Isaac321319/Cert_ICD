#!/bin/bash

#Prevencion de fallo instalación
set -e
trap 'echo "ERROR: Ha ocurrido un fallo durante la instalacion. Se ha cancelado el proceso."; exit 1' ERR

# Comprobacion de si ya se ha instalado Apache
echo "Comprobando si Apache esta instalado..."
if dpkg -s apache2 >/dev/null 2>&1; then
	echo "apache2 ya esta en su sistema"
	exit 0
fi

echo "Aplicando actualizaciones..."
apt-get update

echo "Instalando apache2..."
apt-get install -y apache2

echo "Encendiendo servidor apache2..."
systemctl enable --now apache2

echo "Terminado."

