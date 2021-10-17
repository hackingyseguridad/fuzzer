echo "fuzzer masivo a fqdn en fichero ip.txt"
chmod 777 *
echo "Para mantener como proceso ejecutar: nohup ./fuzzerauto.sh &"
echo "Uso.: ./fuzzerauto.sh "
for n in `cat ip.txt`
do sh fuzzer.sh $n
done
