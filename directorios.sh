########################################
#
# busca carpetas en el sitio web
# hackingyseguriad.com 2025
# https://www.kali.org/tools/dirsearch/
#
# Uso: sh direcitorios.sh url
#
########################################

dirsearch -u $1 $2 -e txt,php,htm,html,asp,jsp -x 200,301 --exclude-status=400-499,500-599 --full-url -t 99 -w carpetas.txt
