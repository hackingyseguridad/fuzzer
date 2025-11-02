

ffuf -w ficheros.txt -u $1/FUZZ $2 -mc 200 -r
