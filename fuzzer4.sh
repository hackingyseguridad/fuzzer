echo
echo "Usdo: sh fuzzer.sh http://www.hackingyseguridad.com"
gobuster dir -e -u $1 -w /usr/share/wordlists/dirb/common.txt
