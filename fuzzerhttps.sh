#!/bin/bash
cat << "INFO"
   __                          _     _   _
  / _|                        | |   | | | |
 | |_ _   _ ___________ _ __  | |__ | |_| |_ _ __
 |  _| | | |_  /_  / _ \ '__| | '_ \| __| __| '_ \
 | | | |_| |/ / / /  __/ |    | | | | |_| |_| |_) |
 |_|  \__,_/___/___\___|_|    |_| |_|\__|\__| .__/  v1.0
                                            | |
          http://www.hackingyseguridad.com  |_|

INFO
if [ -z "$1" ]; then
        echo
        echo "Descubre ficheros en  url de sitio web por 200 OK.. "
        echo "Uso: $0 <https://dominio.com>"
        echo "Tiempo estimado 1 hora .."
        exit 0
fi
echo
echo "Fuzzer de: " $1
echo

for n in `cat diccionario.txt`

do
        fqdn=$1"/"$n
        if curl --cacert MyRootCA.crt -k -s $fqdn -I --silent|grep "200 OK"
        then echo $fqdn
        fi
done

for n in `cat diccionario.txt`

do
        fqdn=$1"/"$n
        if curl --cacert MyRootCA.crt -k -s $fqdn -I --silent|grep "403 OK"
        then echo $fqdn
        fi
done

for n in `cat diccionario.txt`

do
        fqdn=$1"/"$n
        if curl --cacert MyRootCA.crt -k -s $fqdn -I --silent|grep "500 OK"
        then echo $fqdn
        fi
done
