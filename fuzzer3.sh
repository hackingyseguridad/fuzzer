for i in `cat ip.txt`
do
ffuf -w diccionario.txt -H "User-Agent: Googlebot-News" -u http://$i/FUZZ -mc 200
echo $i
done
