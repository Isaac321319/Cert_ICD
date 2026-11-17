#!/bin/bash
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

