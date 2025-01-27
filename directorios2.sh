#!/bin/bash
echo
echo "directorios masivos a fqdn en fichero url.txt"
chmod 777 *
echo "hackingyseguridad.com (2025)"
echo
echo "Uso.: ./directorios2.sh "
for n in `cat url.txt`
do echo "======>" $n
echo
        echo "===>" $n
dirsearch -u $n $1 $2 -e txt,php,htm,html,asp,jsp -x 200,301 --exclude-status=400-499,500-599 --full-url -t 99 -w diccionario.txt
done
