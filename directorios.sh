# busca carpetas en el sitio web
# hackingyseguriadd 2025
# sh direcitorios.sh url
dirsearch -u $1 $2 -e txt,php,html -x 404 --full-url  -w diccionario.txt
