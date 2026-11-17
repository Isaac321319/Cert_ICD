#!/bin/bash

echo "Comprobando si apache2 esta instalado..."

if ! dpkg -s apache2 >/dev/null 2>&1; then
    echo "Error: ejecuta antes install_apache.sh"
    exit 1
fi

# Leer variables de datos.env
echo "Leyendo variables..."
source "$(dirname "$0")/datos.env"

# Crear directorios
mkdir -p "$(dirname "$CERT_PATH")"
mkdir -p "$(dirname "$KEY_PATH")"

# Crear certificado con dominio e IP en el SAN
echo "Creando certificado..."

openssl req -x509 -nodes -days "$VALIDITY_DAYS" -newkey rsa:2048 \
-keyout "$KEY_PATH" -out "$CERT_PATH" \
-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/CN=$DOMAIN/emailAddress=$EMAIL" \
-addext "subjectAltName=DNS:$DOMAIN,IP:$ELASTIC_IP" || exit 1

# Copiar configuracion y sustituir el dominio
echo "Copiando configuracion..."

cp "$(dirname "$0")"/conf/* "$CONF_PATH"

sed -i "s/DOMINIO/$DOMAIN/g" "$CONF_PATH"*.conf
sed -i "s|__CERT_PATH__|$CERT_PATH|g" "$CONF_PATH"*.conf
sed -i "s|__KEY_PATH__|$KEY_PATH|g" "$CONF_PATH"*.conf

# Habilitar modulos y sitio HTTPS
echo "Habilitando modulos y sitio HTTPS..."

a2enmod ssl rewrite
a2ensite default-ssl.conf

# Comprobar configuracion antes de reiniciar
echo "Comprobando configuracion..."

if apache2ctl configtest; then
    systemctl restart apache2
    echo "Hecho."
else
    echo "Error: la configuracion de Apache no es valida"
    exit 1
fi

