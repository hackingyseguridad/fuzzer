#!/bin/bash
echo "uso.: sh dirb.sh url" 
dirb $1 -M 100,204,400,401,403,409,500,503 
dirb $1 diccionario.txt -M 100,204,400,401,403,409,500,503 
dirb $1 diccionario2.txt -M 100,204,400,401,403,409,500,503 
dirb $1 diccionario3.txt -M 100,204,400,401,403,409,500,503 

