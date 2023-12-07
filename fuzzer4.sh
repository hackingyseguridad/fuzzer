echo
echo "Usdo: sh fuzzer.sh http://www.hackingyseguridad.com"
# diccionario:  /usr/share/wordlists/dirb/common.txt
gobuster dir -e -u https://www.zener.es -w diccionario.txt --no-error -z -k -a "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0"
