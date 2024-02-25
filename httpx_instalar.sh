echo
echo "instalar ultima version httpx "
echo
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
cd ~/go/bin
cp httpx /usr/bin/
httpx
