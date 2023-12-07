echo
echo "Usdo: sh fuzzer.sh http://www.hackingyseguridad.com"
# diccionario:  /usr/share/wordlists/dirb/common.txt
gobuster dir -e -u $1 -w diccionario.txt --no-error -z -k -a "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0" -H "Accept: text/html, applicattion/xhtml+xml, application/xml;q=0.9,*/*;q=0.8"
