#!/usr/bin/env bash
echo "##################################################################"
echo "... actualizando diccionarios ...  (R) 2026 hackingyseguridad.com "
echo "##################################################################"
echo
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/http-fingerprints.lua -q -O http-fingerprints.lua  --inet4-only
wc -l http-fingerprints.lua
echo "...."
echo "....."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/ficheros.txt -q -O ficheros.txt  --inet4-only
wc -l ficheros.txt
echo ".."
echo "..."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/ficheros2.txt -q -O ficheros2.txt  --inet4-only
wc -l ficheros2.txt
echo "...."
echo "....."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/carpetas.txt -q -O carpetas.txt  --inet4-only
wc -l carpetas.txt
echo "...."
echo "....."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/carpetas2.txt -q -O carpetas2.txt  --inet4-only
wc -l carpetas2.txt
echo "...."
echo "....."
echo
echo "actualizado !!! "

