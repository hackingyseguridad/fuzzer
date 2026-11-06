echo
echo "instalar ultima version httpx "
echo
sudo apt update
sudo apt install -y golang
echo
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
cd ~/go/bin
cp httpx /usr/bin/
httpx
