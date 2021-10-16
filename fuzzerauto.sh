echo "fuzzer masivo a fqdn en fichero ip.txt"
echo "Uso.: ./fuzzerauto.sh "
for n in `cat ip.txt`
do sh fuzzer.sh $n
done
