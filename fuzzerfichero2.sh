echo
echo "Uso: ./fuzzerfichero2.sh nombre_fichero"
echo "si exite el fichero da codigo de respuesta http 200"
echo
echo "Por ejmplo para WordPress"
echo "cat http.txt | httpx -title -status-code -tech-detect -follow-redirects -path /wp-login.php -mc 200,301,302 -silent"
echo "cat http.txt | httpx-toolkit -title -status-code -tech-detect -follow-redirects -path /wp-admin.php -mc 200,301,302 -silent"
echo 
cat http.txt | httpx -ports 80,443,7443,8000,8009,8080,8081,8090,8180,8443,9443,10443 -path /$1 -status-code -content-length -method -mc 200
