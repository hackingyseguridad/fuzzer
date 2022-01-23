for i in `cat ip.txt`
do
ffuf -w diccionario.txt -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36" -u http://$i/FUZZ -mc 200,204,301,302,307,401
echo $i
done
