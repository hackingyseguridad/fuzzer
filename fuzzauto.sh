#!/bin/bash
echo "fuzzer masivo a fqdn en fichero ip.txt"
chmod 777 *
echo "www.hackingyseguridad.com (2023)"
echo "Para mantener como proceso ejecutar: nohup ./fuzzerauto.sh &"
echo "Uso.: ./fuzzerauto.sh "
for n in `cat ip.txt`
do echo "======>" $n
for p in `cat diccionario.txt`
do
        fqdn="https://$n:443/$p"
       	echo "===>" $fqdn




        then echo $fqdn
        fi
done
done
