echo
echo "codigo de respuesta http" 
echo
cat http.txt | httpx -ports 80,443,7443,8000,8009,8080,8081,8090,8180,8443,9443,10443 -path / -status-code -content-length 
