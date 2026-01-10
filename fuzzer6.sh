# Fuzzer web
# @antonio_taboada
# hackingyseguridad.com 2026


ffuf -w ficheros.txt -u $1/FUZZ $2 -mc 200 -r
ffuf -w ficheros.txt -u $1/FUZZ $2 -mc 200 -r -X POST
ffuf -w ficheros.txt -u $1/FUZZ $2 -mc 200 -r -X PUT
