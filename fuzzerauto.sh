#!/bin/bash
echo "fuzzer masivo a fqdn en fichero ip.txt"
chmod 777 *
echo "Para mantener como proceso ejecutar: nohup ./fuzzerauto.sh &"
echo "Uso.: ./fuzzerauto.sh "
for n in `cat ip.txt`
do sh fuzzer.sh $n
for p in `cat diccionario.txt`
do
        fqdn="http://"$n"/"$p
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
done
