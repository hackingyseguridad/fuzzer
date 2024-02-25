echo 
echo "http_sumbdminio.sh dominio.com"
echo
subfinder -d $1 -silent | httpx -asn
