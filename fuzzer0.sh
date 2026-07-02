#!/bin/sh

# Script compatible con shells antiguos (Bash 1.0.x, sh, ash, dash)
# Usar ficheros2.txt de la misma carpeta del script

# Obtener la ruta del script (método compatible con shells antiguos)
SCRIPT_DIR=`dirname "$0"`
if test -z "$SCRIPT_DIR"; then
    SCRIPT_DIR="."
fi
SCRIPT_DIR=`cd "$SCRIPT_DIR" && pwd`

Default_WORDLIST="${SCRIPT_DIR}/ficheros2.txt"
EXTENSIONS="xml dll svc zip 7z htm html json js aspx asmx ashx debug"
url="$1"
wordlist="${2:-$Default_WORDLIST}"
hostname=`echo "$url" | cut -d "/" -f3`

# Función para validar URL (compatible con shells antiguos)
validate_url() {
    case "$1" in
        http://*|https://*)
            # Extraer la parte sin protocolo
            temp=`echo "$1" | sed 's,^https\?://,,'`
            # Verificar si es IP o dominio
            case "$temp" in
                *.*)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
}

if test -z "$url"; then
    echo "[+] No url specified"
    echo "[+] Uso: $0 <url> [wordlist]"
    exit 1
fi

if ! validate_url "$url"; then
    echo "[+] Url is not correct"
    echo "[+] Ejemplo: http://ejemplo.com o http://192.168.1.1"
    exit 1
fi

if test -f "$wordlist" && test -s "$wordlist"; then
    echo "[+] Fuzzing with wordlist: $wordlist"
    for ext in $EXTENSIONS; do
        echo "[+] Fuzzing Ext: $ext"
        ffuf -u "$url/FUZZ.$ext" -w "$wordlist" -ac -o "${hostname}-ffuf.txt"
    done
else
    echo "[+] The file '$wordlist' doesn't exist or is empty"
    exit 1
fi
