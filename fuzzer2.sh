#!/bin/sh
# Scrip para buscar un fichero en una lista de IP/fqdn
# hackingyseguridad.com
# uso: sh fuzzer2.sh nombre_fichero.ext
echo "..."
cat http.txt | while read S do; do curl -k --connect-timeout 15 --max-time 30 --silent --insecure --user-agent "vAPI/2.100.0 Java/1.8.0_261 (Linux; 4.19.160-6.ph3; amd64)" -I -s "https://$S/$1" |grep "HTTP/1.1 200" && echo $S; done;
