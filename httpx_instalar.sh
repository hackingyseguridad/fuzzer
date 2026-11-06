echo
echo "instalar ultima version httpx "
echo
sudo apt update
sudo apt install -y golang
sudo apt install httpx-toolkit
echo
go clean -cache
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
cd ~/go/bin
cp httpx /usr/bin/
httpx


# Cuando todo falla otro metodo de instalacion del binario
# 
# cd /tmp
# wget https://github.com/projectdiscovery/httpx/releases/download/v1.12.0/httpx_1.12.0_linux_amd64.zip
# unzip httpx_1.12.0_linux_amd64.zip
# cp httpx /usr/bin/
# mv httpx /usr/local/bin/httpx


