echo
echo "Uso: sh fuzzer4.sh http://www.hackingyseguridad.com"

# diccionario Kali:  /usr/share/wordlists/dirb/common.txt

wfuzz -c -z file,ficheros.txt --hc 301,302,400,401,403,404,405,411,500,503 $1/FUZZ

