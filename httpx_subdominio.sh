echo 
echo "httpx_sumbdminio.sh dominio.com"
echo "subfinder -d $1 -silent | httpx  -ports 443 -asn"
echo 
subfinder -d $1 -silent | httpx  -asn
