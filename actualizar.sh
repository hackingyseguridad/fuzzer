#!/usr/bin/env bash
echo
echo "... actualizando diccionario ...  (R) 2025 hackingyseguridad.com "
echo
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/ficheros.txt -q -O diccionario.txt  --inet4-only
echo "."
echo ".."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/ficheros2.txt -q -O diccionario2.txt  --inet4-only
echo "..."
echo "...."
echo
echo "actualizado !!! "
