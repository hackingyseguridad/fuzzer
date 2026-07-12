```
███████╗██╗   ██╗███████╗███████╗███████╗██████╗
██╔════╝██║   ██║╚══███╔╝╚══███╔╝██╔════╝██╔══██╗
█████╗  ██║   ██║  ███╔╝   ███╔╝ █████╗  ██████╔╝
██╔══╝  ██║   ██║ ███╔╝   ███╔╝  ██╔══╝  ██╔══██╗
██║     ╚██████╔╝███████╗███████╗███████╗██║  ██║
╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
```

# fuzzer — Fuzzing HTTP/HTTPS y descubrimiento de contenido web

Colección de scripts en **Bash** y **Python** para el descubrimiento de ficheros, carpetas y rutas ocultas en servidores web, junto con utilidades de apoyo para pruebas de intrusión (bypass de 403, detección de WAF, extracción de secretos, análisis con `httpx`, generación de certificados para MITM/HTTPS, etc.).

El proyecto original es de [hackingyseguridad.com](http://www.hackingyseguridad.com/) — este documento amplía el README original añadiendo una descripción detallada de cada script, ejemplos de uso y una guía sobre cómo interpretar los resultados de las pruebas de fuzzing.

> ⚠️ **Aviso legal:** estas herramientas están pensadas exclusivamente para auditorías de seguridad autorizadas, laboratorios propios (CTF, entornos de pruebas) o programas de *bug bounty* que expresamente permitan este tipo de pruebas. Lanzar un fuzzer contra un dominio sin autorización explícita del propietario puede constituir un delito. El uso de estas herramientas es responsabilidad exclusiva de quien las ejecuta.

---

## Tabla de contenidos

- [¿Qué es el fuzzing HTTP?](#qué-es-el-fuzzing-http)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Scripts de fuzzing principales](#scripts-de-fuzzing-principales)
- [Descubrimiento de directorios](#descubrimiento-de-directorios)
- [Bypass de 403 / 40x y WAF](#bypass-de-403--40x-y-waf)
- [Herramientas basadas en httpx](#herramientas-basadas-en-httpx)
- [Otras utilidades](#otras-utilidades)
- [Códigos de respuesta HTTP](#códigos-de-respuesta-http)
- [Interpretar los resultados de un fuzz](#interpretar-los-resultados-de-un-fuzz)
- [Buenas prácticas al fuzzear](#buenas-prácticas-al-fuzzear)
- [Licencia](#licencia)

---

## ¿Qué es el fuzzing HTTP?

El *fuzzing* de contenido web consiste en lanzar peticiones HTTP/HTTPS contra un servidor probando de forma masiva y automática combinaciones de rutas (ficheros, carpetas, parámetros) tomadas de un diccionario, con el objetivo de encontrar recursos que no están enlazados públicamente: paneles de administración, copias de seguridad (`.bak`, `.zip`, `.sql`), ficheros de configuración, código fuente expuesto, endpoints de API, etc.

El fuzzer clasifica cada ruta probada según el **código de respuesta HTTP** devuelto por el servidor (200, 301, 302, 403, 500...), lo que permite distinguir entre recursos accesibles, redirecciones, recursos prohibidos o errores del servidor.

---

## Requisitos

Los scripts dependen de herramientas que deben estar instaladas en el sistema (la mayoría vienen preinstaladas en **Kali Linux**):

| Herramienta | Uso | Instalación (Debian/Kali) |
|---|---|---|
| `curl` | Motor de peticiones HTTP de la mayoría de scripts | `apt install curl` |
| `dirsearch` | Motor de descubrimiento de directorios (usado por `directorios*.sh`, `dirb.sh`) | `apt install dirsearch` |
| `httpx` (ProjectDiscovery) | Sondeo masivo de hosts/URLs, huellas de servidor y subdominios | ver `httpx_instalar.sh` |
| `nmap` | Escaneo de puertos/servicios combinado con fuzzing | `apt install nmap` |
| `openssl` | Generación de la CA y certificados usados por `generacert.sh` | `apt install openssl` |
| Python 3 | Ejecución de los scripts `.py` (`403bypass.py`, `403bypass2.py`, `403bypass3.py`) | `apt install python3` |
| Bash ≥ 4 | Ejecución de los scripts `.sh` | preinstalado en la mayoría de distros |

---

## Instalación

```bash
git clone https://github.com/hackingyseguridad/fuzzer
cd fuzzer
chmod 777 *
sh instalar.sh        # instala/comprueba dependencias necesarias
sh generacert.sh       # genera la CA raíz y el certificado usado en las peticiones HTTPS
```

`generacert.sh` crea `MyRootCA.crt`, que los scripts usan con `curl --cacert MyRootCA.crt -k` para poder interceptar/verificar tráfico HTTPS durante las pruebas.

Para mantener las listas de palabras y el propio fuzzer actualizados:

```bash
sh actualizar.sh
```

---

## Estructura del repositorio

```
fuzzer/
├── ficheros.txt                 # diccionario principal de rutas/ficheros a probar
├── carpetas.txt / carpetas2.txt # diccionarios de carpetas (usados por directorios*.sh)
├── headers.txt                  # cabeceras HTTP usadas en las pruebas de bypass
├── Codigos_respuesta_http.txt   # referencia de códigos de estado HTTP
├── MyRootCA.crt                 # certificado generado por generacert.sh (tras instalación)
├── fuzzer*.sh / fuzzer*.py      # fuzzers de rutas/ficheros
├── fuzzerauto*.sh               # versiones automatizadas (encadenan varias fases)
├── fuzzernmap*.sh               # fuzzing combinado con escaneo nmap
├── fuzzerfichero*.sh            # fuzzing centrado en un fichero/extensión concreto
├── directorios*.sh, dirb.sh     # descubrimiento de directorios con dirsearch/dirb
├── 403bypass*.sh / .py          # técnicas de bypass de HTTP 403 Forbidden
├── 40xbypass.sh                 # bypass genérico para códigos 4xx
├── wafbypass*.sh                # técnicas de evasión de WAF
├── httpx_*.sh                   # sondeo de hosts, subdominios e info de servidor con httpx
├── buscasecretos.sh             # búsqueda de secretos/credenciales expuestas
├── explorarweb.sh / probarweb.sh# exploración y pruebas generales del sitio
├── metodotrace.sh               # comprobación del método HTTP TRACE
├── as2http.sh                   # conversión/pruebas de tráfico HTTPS a HTTP
├── generacert.sh                # generación de CA/certificados para pruebas HTTPS
├── instalar.sh / actualizar.sh  # instalación y actualización del entorno
└── 403.jpg, HTTP_codigos.jpg, codigoshttp.png  # material gráfico de apoyo
```

---

## Scripts de fuzzing principales

### `fuzzer.sh` — fuzzer base

```bash
sh fuzzer.sh https://dominio.com
```

- Lee el diccionario `ficheros.txt` y concatena cada entrada a la URL objetivo.
- Lanza una petición `HEAD` (`curl -I`) por cada ruta con `--cacert MyRootCA.crt -k`, cabeceras de navegador realista (`User-Agent`, `Accept`, `Accept-Language`...) y un timeout de 1 segundo por petición.
- Filtra y muestra únicamente las rutas que responden `100`, `200`, `300`, `301` o `302`.
- Al final imprime una tabla con el significado de cada código HTTP relevante (200 OK, 301/302 redirección, 403 prohibido, 404 no encontrado, 500 error interno, etc.).
- Tiempo estimado de ejecución: ~1 hora (depende del tamaño del diccionario y la latencia del objetivo).

### Variantes numeradas `fuzzer0.sh` … `fuzzer9.sh`

Mismo motor que `fuzzer.sh` pero con variaciones en el diccionario utilizado, el conjunto de códigos de estado filtrados o las cabeceras enviadas. Se recomienda ejecutarlas de forma incremental (`fuzzer0.sh`, `fuzzer1.sh`, ...) cuando se quiere cubrir diccionarios distintos sin repetir peticiones ya lanzadas por `fuzzer.sh`.

```bash
sh fuzzer3.sh https://dominio.com
```

### `fuzzerauto.sh`, `fuzzerauto1.sh`, `fuzzerauto2.sh` — fuzzing automatizado

Encadenan varias fases de fuzzing (distintos diccionarios/scripts) en una sola ejecución, pensadas para lanzar un barrido completo sin intervención manual:

```bash
sh fuzzerauto.sh https://dominio.com
```

### `fuzzernmap.sh`, `fuzzernmap2.sh` — fuzzing + nmap

Combinan el descubrimiento de rutas con un escaneo de puertos/servicios vía `nmap`, útil para correlacionar los servicios expuestos por el host con los recursos web encontrados:

```bash
sh fuzzernmap.sh dominio.com
```

### `fuzzerfichero.sh`, `fuzzerfichero2.sh` — fuzzing de un fichero concreto

Permiten centrar la búsqueda en un nombre de fichero o extensión específica (por ejemplo, backups `.zip`/`.sql`, ficheros `.env`, etc.) en lugar de recorrer el diccionario completo:

```bash
sh fuzzerfichero.sh https://dominio.com nombre_fichero
```

---

## Descubrimiento de directorios

### `directorios.sh`

```bash
sh directorios.sh https://dominio.com
```

Es un *wrapper* sobre [`dirsearch`](https://www.kali.org/tools/dirsearch/) (herramienta de Kali Linux). Ejecuta dos pasadas, una por cada diccionario de carpetas (`carpetas.txt` y `carpetas2.txt`):

```bash
dirsearch -u $1 -e txt,php,htm,html,asp,jsp -x 200,301 --exclude-status=400-499,500-599 --full-url -t 99 -w carpetas.txt
dirsearch -u $1 -e txt,php,htm,html,asp,jsp -x 200,301 --exclude-status=400-499,500-599 --full-url -t 99 -w carpetas2.txt
```

- `-e`: extensiones a probar (txt, php, htm, html, asp, jsp).
- `-x 200,301`: excluye explícitamente esos códigos del filtro de exclusión (es decir, se muestran).
- `--exclude-status=400-499,500-599`: oculta del resultado los errores de cliente/servidor.
- `-t 99`: 99 hilos concurrentes.
- `-w`: diccionario de carpetas a usar.

### `directorios1.sh`, `directorios2.sh`

Variantes con diccionarios o parámetros de `dirsearch` distintos (extensiones adicionales, exclusiones diferentes) para ampliar la cobertura sin repetir el mismo barrido.

### `dirb.sh`

Alternativa apoyada en [`dirb`](https://www.kali.org/tools/dirb/) en lugar de `dirsearch`, útil cuando se prefiere su motor de fuerza bruta recursivo:

```bash
sh dirb.sh https://dominio.com
```

---

## Bypass de 403 / 40x y WAF

Cuando el fuzzer encuentra una ruta que devuelve `403 Forbidden`, estos scripts prueban técnicas conocidas para intentar acceder igualmente al recurso.

### `403bypass.sh`, `403bypass1.sh` … `403bypass9.sh`

Prueban la misma ruta prohibida repitiendo la petición con distintas **cabeceras de IP falsificada**, simulando que la petición proviene del propio servidor (`localhost`/`127.0.0.1`). Entre las cabeceras utilizadas (ver `headers.txt`) se incluyen variantes como:

- `X-Forwarded-For`, `X-Forwarded`, `X-Forward-For`
- `X-Real-IP`, `X-Client-IP`, `X-Originating-IP`
- `Client-IP`, `True-Client-IP`, `X-Remote-IP`, `X-Remote-Addr`
- `X-Host`, `X-Forwarded-Server`, `X-Forwarded-By`
- `X-Custom-IP-Authorization`, `X-HTTP-Host-Override`

cada una probada tanto con `127.0.0.1` como con `localhost`.

```bash
sh 403bypass.sh https://dominio.com/ruta-prohibida
```

Cada script numerado (`403bypass1.sh`...`403bypass9.sh`) va probando subconjuntos distintos de cabeceras o técnicas complementarias, como:

- variaciones de *path* (`/ruta%2f`, `/ruta/.`, `/RUTA`, `/ruta/./`, doble barra `//ruta`);
- cambios de método HTTP (`GET`, `POST`, `HEAD`);
- manipulación de la cabecera `X-Original-URL` / `X-Rewrite-URL`.

### `403bypass.py`, `403bypass2.py`, `403bypass3.py`

Versiones en Python de las mismas técnicas, pensadas para integrarse en flujos de trabajo más complejos o para facilitar la extensión con nuevas cabeceras/rutas:

```bash
python3 403bypass2.py https://dominio.com/ruta-prohibida
```

### `40xbypass.sh`

Generaliza el enfoque anterior a cualquier código de la familia 4xx (401, 403, 404 "falso"), no solo 403.

### `wafbypass.sh`, `wafbypass2.sh`

Prueban técnicas de evasión de **WAF** (Web Application Firewall): variación de *User-Agent*, *encoding* de la URL, cabeceras adicionales, fragmentación de payloads, etc., para comprobar si el WAF bloquea la petición original pero deja pasar una variante equivalente.

```bash
sh wafbypass.sh https://dominio.com/ruta
```

---

## Herramientas basadas en httpx

[`httpx`](https://github.com/projectdiscovery/httpx) es la herramienta de ProjectDiscovery para sondeo masivo de hosts HTTP/HTTPS.

- **`httpx_instalar.sh`** — instala/actualiza `httpx` en el sistema.
- **`httpx_code.sh`** — sondea una lista de URLs y muestra el código de estado devuelto por cada una, útil para clasificar rápidamente grandes listas de rutas o subdominios ya descubiertos.
- **`httpx_servidor_info.sh`** — extrae huella tecnológica del servidor (cabecera `Server`, tecnologías detectadas, títulos de página, etc.).
- **`httpx_subdominio.sh`** — combina un listado de subdominios con `httpx` para comprobar cuáles están vivos y qué responden.

```bash
sh httpx_instalar.sh
sh httpx_code.sh lista_urls.txt
sh httpx_servidor_info.sh lista_urls.txt
sh httpx_subdominio.sh subdominios.txt
```

---

## Otras utilidades

| Script | Función |
|---|---|
| `buscasecretos.sh` | Rastrea el contenido descubierto en busca de patrones de secretos/credenciales expuestas (claves de API, tokens, contraseñas en ficheros de configuración, etc.). |
| `explorarweb.sh` | Exploración general del sitio (enlaces, recursos estáticos) como paso previo al fuzzing dirigido. |
| `probarweb.sh` | Batería de comprobaciones básicas sobre la disponibilidad y comportamiento del sitio objetivo. |
| `metodotrace.sh` | Comprueba si el servidor tiene habilitado el método HTTP `TRACE` (potencial vector de *Cross-Site Tracing*). |
| `as2http.sh` | Pruebas/soporte para tráfico HTTPS→HTTP durante el fuzzing. |
| `generacert.sh` | Genera la CA raíz (`MyRootCA.crt`) y certificados usados por el resto de scripts para las peticiones HTTPS. |
| `instalar.sh` | Instala las dependencias necesarias para ejecutar el conjunto de scripts. |
| `actualizar.sh` | Actualiza el repositorio y los diccionarios a la última versión. |

---

## Códigos de respuesta HTTP

Los scripts clasifican los hallazgos según el código devuelto por el servidor. Referencia rápida (ampliada en `Codigos_respuesta_http.txt`):

| Código | Significado | Relevancia en el fuzzing |
|---|---|---|
| 200 | OK | Recurso accesible directamente — revisar contenido. |
| 301 / 302 | Redirección permanente / temporal | El recurso existe pero redirige; seguir la redirección. |
| 304 | No modificado | Recurso cacheado, existe. |
| 400 | Solicitud incorrecta | Posible parámetro/formato mal interpretado por el servidor. |
| 401 | No autorizado | Requiere autenticación — candidato a pruebas de fuerza bruta/bypass. |
| 403 | Prohibido | El recurso existe pero el acceso está bloqueado — candidato a `403bypass*`. |
| 404 | No encontrado | Ruta inexistente (ruido, se descarta). |
| 410 | Ya no disponible | Existió pero fue retirado. |
| 500 | Error interno del servidor | Puede indicar un endpoint mal gestionado, revisar manualmente. |

---

## Interpretar los resultados de un fuzz

1. **Prioriza los `200` y `301/302`**: son los hallazgos más directos, revisa el contenido devuelto.
2. **Cataloga los `403`**: no los descartes — ejecuta `403bypass*.sh`/`wafbypass*.sh` sobre esas rutas concretas antes de darlas por perdidas.
3. **Vigila los `500`**: pueden delatar errores de lógica o endpoints que esperan parámetros específicos.
4. **Cruza resultados**: combina la salida de `directorios.sh` (carpetas) con `fuzzerfichero.sh` (ficheros dentro de esas carpetas) para ampliar la cobertura.
5. **Verifica falsos positivos**: algunos servidores devuelven `200` para cualquier ruta (páginas *catch-all* o *soft 404*); compara el tamaño/contenido de la respuesta antes de confirmar un hallazgo.

---

## Buenas prácticas al fuzzear

- Ejecuta siempre contra objetivos para los que tengas **autorización explícita**.
- Ajusta la concurrencia/hilos (`-t` en `dirsearch`) para no provocar una denegación de servicio involuntaria.
- Usa un `User-Agent` identificable si el cliente lo solicita, para que el equipo defensivo pueda distinguir tu tráfico de un ataque real.
- Guarda las salidas (`> resultado.txt`) de cada script para poder correlacionar hallazgos entre fases (directorios → ficheros → bypass 403).
- Actualiza regularmente los diccionarios (`actualizar.sh`) para no perder rutas relevantes que aparecen con nuevas versiones de frameworks/CMS.

---

## Licencia

Este proyecto se distribuye bajo licencia **GPL-3.0**. Consulta el fichero [`LICENSE`](./LICENSE) para más detalles.

Proyecto original: [hackingyseguridad.com](http://www.hackingyseguridad.com/) · [github.com/hackingyseguridad/fuzzer](https://github.com/hackingyseguridad/fuzzer)



#
http://www.hackingyseguridad.com/
#

