
echo
echo "Uso: sh fuzzer5.sh http://www.hackingyseguridad.com"

# diccionario Kali :  /usr/share/wordlists/dirb/common.txt

gobuster dir -e -u $1 $2 -w ficheros.txt --no-error -z -k -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -r
gobuster dir -e -u $1 $2 -w ficheros.txt -x .php,.html
