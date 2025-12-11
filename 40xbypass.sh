#!/bin/bash
# (c) Hacking y Seguridad .COM 2023
# Busca recursos web que devuelevan codigo 401 o 403 http
cat << "INFO"
  _  _    ___             _
 | || |  / _ \           | |
 | || |_| | | |_  __  ___| |__
 |__   _| | | \ \/ / / __| '_ \
    | | | |_| |>  < _\__ \ | | |
    |_|  \___//_/\_(_)___/_| |_| v 1.0
    http://www.hackingyseguridad.com/
INFO
if [ -z "$1" ]; then
        echo
        echo "Uso: $0 <https://dominio.com>"
        echo "Tiempo estimado 2 hora ..."
        exit 0
fi
echo
echo "Fuzz de: " $1
echo
dirb  $1 ficheros.txt -M 401,403 -f -w  -z 99 -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8"
