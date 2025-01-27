# busca carpetas en el sitio web
# hackingyseguriad.com 2025
# https://www.kali.org/tools/dirsearch/
# sh direcitorios.sh url
#

dirsearch -u $1 $2 -e txt,php,htm,html,asp -x 404 --full-url  -w diccionario.txt
