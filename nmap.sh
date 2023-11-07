#!/bin/bash
echo
echo "(C) hackingyseguridad.com 2023"
echo
echo "Uso.: sh nmap.sh IP/fqdn"
echo
nmap $1 $2 -Pn -sV --open --script=http-enum --script-args http-enum.basepath=diccionario.txt  
