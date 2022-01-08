for i in `cat ip.txt`
do
ffuf -w diccionario.txt -u http://$i/FUZZ -mc 200
echo $i
done
