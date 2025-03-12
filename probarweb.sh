#!/bin/bash
# Prueba portales web https, de una lista  IP y fqdn en el fichero portales.txt
# hackingyseguridad.com 2025
# Uso: sh probarweb.sh nombre_fichero.txt

echo
echo "..."
echo
for S in `cat fqdn.txt`; do if timeout 1 curl  -k -s -I --connect-timeout 15 --max-time 30 --silent -X "GET" https://$S/$1 -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8" | grep "HTTP/2 200\|HTTP/1.1 200\|HTTP/1.1 300\|HTTP/1.1 301\|HTTP/1.1 302"
        then echo $S && echo
        fi
done


