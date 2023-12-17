#!/bin/sh
# Scrip para buscar un fichero en una lista de IP/fqdn en el fichero ip.txt
# cat ip.txt | while read S do; do curl -sk --connect-timeout 15 --max-time 30 --silent --insecure --user-agent "vAPI/2.100.0 Java/1.8.0_261 (Linux; 4.19.160-6.ph3; amd64)" -I --path-as-is "https://$S/robots.txt" |grep "HTTP/1.1 200" && echo $S; done;
# hackingyseguridad.com
# Uso: sh fuzzer2.sh nombre_fichero.ext o resto de la url
echo
echo "..."
echo
for S in `cat ip.txt`; do if timeout 1 curl  -k -s -I --connect-timeout 15 --max-time 30 --silent -X "GET" https://$S/$1 -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8" -H 'Content-Type: application/json' -H "X-Forwarded-For: $S" \ |grep "200"
        then echo $S "Vulnerable ???"
             #  curl -k -v https://$S/$1
        fi
done


