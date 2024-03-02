echo
echo "Uso: ./fuzzerfichero2.sh nombre_fichero"
echo "si exite el fichero da codigo de respuesta http 200"
echo
cat http.txt | httpx -ports 80,443,7443,8000,8009,8080,8081,8090,8180,8443,9443,10443 -path /$1 -status-code -content-length -method -mc 200
