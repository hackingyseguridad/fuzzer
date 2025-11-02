#!/bin/bash
echo "fuzzer masivo a fqdn en fichero ip.txt"
chmod 777 *
echo "www.hackingyseguridad.com (2024)"
echo "Para mantener como proceso ejecutar: nohup ./fuzzerauto.sh &"
echo "Uso.: ./fuzzerauto2.sh "
for n in `cat ip.txt`
do echo "======>" $n

        fqdn="https://$n:443"
        echo "===>" $fqdn
        gobuster dir -e -u $fqdn -w ficheros.txt --no-error -k -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -r $1 $2
done
