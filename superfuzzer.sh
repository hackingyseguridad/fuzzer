#!/bin/bash

# Verificar que se haya proporcionado una URL

if [ -z "$1" ]; then
    echo "Uso: $0 <url>"
    echo "Ejemplo: $0 ejemplo.com"
    exit 1
fi

TARGET="$1"
PORTS=(80 443 8443)
ARCHIVO_RUTAS="ficheros.txt"

echo "========================================="
echo " Analizando: $TARGET"
echo "========================================="

# 1. Comprobar puertos TCP habituales (80, 443, 8443)
echo "[*] Comprobando puertos web habituales..."
for PORT in "${PORTS[@]}"; do
    # Usamos /dev/tcp de bash para una comprobación rápida sin dependencias externas
    if timeout 2 bash -c "echo > /dev/tcp/$TARGET/$PORT" 2>/dev/null; then
        echo "    [+] Puerto $PORT: ABIERTO"
    else
        echo "    [-] Puerto $PORT: CERRADO o FILTRADO"
    fi
done

echo ""
echo "[*] Ejecutando httpx-toolkit..."

# 2. Ejecutar httpx-toolkit con los parámetros solicitados
# Verificamos si existe el archivo de rutas, si no, lo creamos vacío para evitar errores
if [ ! -f "$ARCHIVO_RUTAS" ]; then
    echo "    [!] No se encontró '$ARCHIVO_RUTAS'. Se creará uno vacío."
    touch "$ARCHIVO_RUTAS"
fi

# Construimos la URL base para httpx (añadimos esquema si falta)
# httpx suele manejar bien los dominios sin esquema, pero forzamos http/https
if [[ ! "$TARGET" =~ ^https?:// ]]; then
    TARGET_URL="https://$TARGET"
else
    TARGET_URL="$TARGET"
fi

httpx-toolkit -u "$TARGET_URL" \
    -title \
    -status-code \
    -tech-detect \
    -follow-redirects \
    -path "$ARCHIVO_RUTAS" \
    -mc 200 \
    -silent

echo ""
echo "========================================="
echo " Análisis finalizado."
echo "========================================="
