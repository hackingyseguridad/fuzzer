

ffuf -w diccionario.txt -u $1/FUZZ $2 -mc 200 -r
