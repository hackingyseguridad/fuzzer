#!/bin/bash
echo "fuzzer masivo a fqdn en fichero ip.txt"
chmod 777 *
echo "www.hackingyseguridad.com (2023)"
echo "Para mantener como proceso ejecutar: nohup ./fuzzauto.sh &"
echo "Uso.: ./fuzzauto.sh "
for n in `cat ip.txt`
        do fqdn="http://$n" ;  echo FQDN "===>" $fqdn ; dirb  $fqdn ficheros.txt -M 100,204,307,400,401,403,409,500,503 -w -f
done


