#!/bin/bash
cat << "INFO"
   __                          _     _   _
  / _|                        | |   | | | |
 | |_ _   _ ___________ _ __  | |__ | |_| |_ _ __
 |  _| | | |_  /_  / _ \ '__| | '_ \| __| __| '_ \
 | | | |_| |/ / / /  __/ |    | | | | |_| |_| |_) |
 |_|  \__,_/___/___\___|_|    |_| |_|\__|\__| .__/
                                            | |
                     hackingyseguridad.com  |_|

INFO
if [ -z "$1" ]; then
        echo
        echo "Descubre ficheros en  url de sitio web por 200 OK.. "
        echo "Uso: $0 <http://dominio.com>"
        exit 0
fi
echo
echo "Fuzzer de: " $1
echo

for n in `cat diccionario.txt`

do
        fqdn=$1"/"$n
        if curl $fqdn -I --silent|grep "HTTP/1.1 200 OK"
        then echo $fqdn
        fi
done
