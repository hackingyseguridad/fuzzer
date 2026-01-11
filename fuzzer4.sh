echo
echo "Uso: sh fuzzer4.sh http://www.hackingyseguridad.com"

# diccionario Kali:  /usr/share/wordlists/dirb/common.txt

wfuzz -c -z file,ficheros.txt --hc 404 $1/FUZZ

