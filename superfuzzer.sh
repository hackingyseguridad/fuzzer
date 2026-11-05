#!/bin/sh

# =========================================
#  superfuzzer.sh - hackingyseguridad.com 
#  Compatible con sh / Bash 1.0.x
# =========================================

# Verificar que se haya proporcionado una URL
if [ -z "$1" ]; then
    echo "Uso: $0 <url>"
    echo "Ejemplo: $0 ejemplo.com"
    exit 1
fi

TARGET="$1"
ARCHIVO_RUTAS="ficheros.txt"


# User-Agent creíble (Chrome 131 en Windows 10)
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

echo "========================================="
echo " Analizando: $TARGET"
echo "========================================="

# 1. Comprobar puertos TCP habituales (80, 443, 4443, 6443, 7443, 8443, 8088, 8000, 8888, 10443)
echo "[*] Comprobando puertos web habituales..."
for PORT in 80 443 4443 6443 7443 8443 8088 8000 8888 10443; do
    # Usamos 'nc' (netcat) compatible con sh y versiones antiguas.
    # -z escanea sin enviar datos, -w establece timeout.
    if nc -z -w 2 "$TARGET" "$PORT" 2>/dev/null; then
        echo "    [+] Puerto $PORT: ABIERTO"
    else
        echo "    [-] Puerto $PORT: CERRADO o FILTRADO"
    fi
done

echo ""
echo "[*] Ejecutando httpx-toolkit..."

# 2. Construimos la URL base (sin usar [[ ]] ni =~)
case "$TARGET" in
    http://*|https://*)
        TARGET_URL="$TARGET"
        ;;
    *)
        TARGET_URL="https://$TARGET"
        ;;
esac

# 3. Ejecutamos httpx-toolkit con los parámetros solicitados
httpx-toolkit -u "$TARGET_URL" \
    -title \
    -status-code \
    -tech-detect \
    -follow-redirects \
    -path "$ARCHIVO_RUTAS" \
    -mc 200,301,302 \
    -silent \
    -H "User-Agent: $USER_AGENT" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" \
    -H "Accept-Language: es-ES,es;q=0.9,en;q=0.8" \
    -H "Accept-Encoding: gzip, deflate, br" \
    -H "Connection: keep-alive" \
    -H "Upgrade-Insecure-Requests: 1"

echo ""


