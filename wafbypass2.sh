#!/bin/sh
#
#
#
#
#
#
echo
echo "==============================================="
echo "Bypassing WAF"
echo "(r) hackingyseguridad.com 2026
URL="$1"
[ -z "$URL" ] && echo "Uso: $0 http://url" && exit 1
OUTPUT=$(curl -s -k -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "test=\u0074\u0065\u0073\u0074" \
  -w "||HTTP_CODE=%{http_code}||TIME=%{time_total}s||" \
  "$URL" 2>&1)
RESPONSE=$(echo "$OUTPUT" | sed 's/||.*//')
HTTP_CODE=$(echo "$OUTPUT" | grep -o 'HTTP_CODE=[0-9]*' | cut -d= -f2)
TIME=$(echo "$OUTPUT" | grep -o 'TIME=[0-9.]*' | cut -d= -f2)
echo "==============================================="
echo "HTTP: $HTTP_CODE"
echo "Tiempo: ${TIME}s"
echo ""
[ -n "$RESPONSE" ] && echo "Respuesta: $RESPONSE" || echo "Sin respuesta!"
