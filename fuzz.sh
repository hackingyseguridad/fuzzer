#!/bin/bash
# (c) Hacking y Seguridad .COM 2023
#
cat << "INFO"
   __                  _     _   _
  / _|                | |   | | | |
 | |_ _   _ _________ | |__ | |_| |_ _ __  ___
 |  _| | | |_  /_  /  | '_ \| __| __| '_ \/ __|
 | | | |_| |/ / / /   | | | | |_| |_| |_) \__ \
 |_|  \__,_/___/___\  |_| |_|\__|\__| .__/|___/ v 1.00
           ALDEA DEL FRESNO / MADRID / ESPAÑA 
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
dirb  $1 diccionario.txt -M 100,204,307,400,401,403,409,500,503 -f

