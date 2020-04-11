#!/bin/bash
cat << "INFO"
   __                          _     _   _             
  / _|                        | |   | | | |            
 | |_ _   _ ___________ _ __  | |__ | |_| |_ _ __  ___ 
 |  _| | | |_  /_  / _ \ '__| | '_ \| __| __| '_ \/ __|
 | | | |_| |/ / / /  __/ |    | | | | |_| |_| |_) \__ \
 |_|  \__,_/___/___\___|_|    |_| |_|\__|\__| .__/|___/ v 2.01
                                            | |        
         http://www.hackingyseguridad.com   |_|        
INFO
if [ -z "$1" ]; then
        echo
        echo "Genera CA root y certificados para las peticiones https "
        echo "Descubre ficheros en  url de sitio web por 200 OK.. "
        echo "Uso: $0 <https://dominio.com>"
        echo "Tiempo estimado 1 hora ..."
        exit 0
fi
echo
echo "Fuzzer de: " $1
echo

for n in `cat diccionario.txt`

do
        fqdn=$1"/"$n
        if timeout 1 curl --cacert MyRootCA.crt -k -s $fqdn -I --silent  \
-H 'Pragma: no-cache' \
-H 'Cache-Control: no-cache' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Accept-Language: es-ES,es;q=0.9,en;q=0.8' \ |grep "100\|200\|300\|301\|302\|401\|403\|405\|500"
        then echo $fqdn
        fi
done
