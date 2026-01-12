#!/bin/sh

TIMEOUT=15

while read host
do
    url="https://$host"
    echo "Probando ===================================>    $url"

        timeout $TIMEOUT wfuzz -w ficheros.txt \
              -u "$url/FUZZ" \
              $1 \
              --hc 301,302,400,401,403,404,405,411,500,503 \
              -X GET
    echo "..."
done < ip.txt

