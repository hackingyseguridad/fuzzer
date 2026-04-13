#!/bin/bash
for n in `cat ip.txt`
do echo "======>" $n

        fqdn="https://$n:443"
        echo "===>" $fqdn
dirsearch -u $fqdn $1 $2 -e txt,php,htm,html,asp,jsp -x 200 --exclude-status=300-399,400-499,500-599 --full-url -t 99 -w carpetas2.txt

done
