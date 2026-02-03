
# (r) hackingyseguridad.com 2026
# Fuzzer con nmap
# unzip http-fingerprints.lua.zip
nmap -Pn -p 443 $1 $2 -sV --script=http-enum --script-args=http-enum.fingerprintfile=http-fingerprints.lua --open -oN resultado.txt 
