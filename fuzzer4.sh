echo
echo "Usdo: sh fuzzer.sh http://www.hackingyseguridad.com"
# diccionario:  /usr/share/wordlists/dirb/common.txt
gobuster dir -e -u $1 -w diccionario.txt --no-error -z -k -a "
