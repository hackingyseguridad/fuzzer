#!/bin/bash
echo
echo "(C) hackingyseguridad.com 2023"
echo
echo "Uso.: sh nmap.sh IP/fqdn"
echo
nmap -Pn -sV --open --script=http-enum
