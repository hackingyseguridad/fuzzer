#!/bin/sh
# (r) HackingySeguridad.COM 2026
# @antonio_taboada

cat << "INFO"
   __                  _     _   _
  / _|                | |   | | | |
 | |_ _   _ _________ | |__ | |_| |_ _ __  ___
 |  _| | | |_  /_  /  | '_ \| __| __| '_ \/ __|
 | | | |_| |/ / / /   | | | | |_| |_| |_) \__ \
 |_|  \__,_/___/___\  |_| |_|\__|\__| .__/|___/ v1.10 (Mayo de 2024)
           ALDEA DEL FRESNO / MADRID / ESPAÑA
           http://www.hackingyseguridad.com/
           (https://github.com/hackingyseguridad/fuzzer/)
INFO
if [ -z "$1" ]; then
        echo
        echo "Uso: $0 <https://dominio.com>"
        echo "Tiempo estimado 1 hora ..."
        exit 0
fi
echo
echo "Fuzz de: " $1
echo
echo "Cod Significado"
echo "--- -----------"
echo "200 OK"
echo "301 Movido permamentemente"
echo "302 Encontrado"
echo "304 No modificado"
echo "400 Solicitud incorrecta"
echo "400 No autorizado"
echo "403 Prohibido"
echo "404 No encontrado"
echo "410 Ya no esta disponible"
echo "500 Error interno en el servidor"
echo

dirsearch -u $n $1 $2 -e txt,php,htm,html,asp,jsp -x 200 --exclude-status=300-399,400-499,500-599 --full-url -t 99 -w carpetas.txt

wfuzz -c -z file,ficheros.txt --hc 301,302,400,401,403,404,405,411,500,503 $1/FUZZ

gobuster dir -e -u $1 $2 -w ficheros.txt --no-error -z -k -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -r

gobuster dir -e -u $1 $2 -w ficheros.txt -x .php,.html

dirb  $1 ficheros.txt -N 302 204 307 400 401 403 409 500 503 -b -f -w -S -z 99 -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8"
