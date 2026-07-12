# 🔍 fuzzer

**Fuzzer HTTP/HTTPS** para descubrir archivos y directorios ocultos en un sitio web mediante fuerza bruta con diccionario, más un conjunto de scripts para bypass de errores 403/40x.


---

## 📋 Resumen

| | |
|---|---|
| **Lenguajes** | Python (52%) · Shell (48%) |
| **Función principal** | Descubrimiento de rutas web (directory/file brute-forcing) |
| **Función secundaria** | Bypass de restricciones HTTP 403 |
| **Licencia** | GPL-3.0 |
| **Forks** | 3 |

---

## ⚙️ Instalación

```bash
git clone https://github.com/hackingyseguridad/fuzzer
cd fuzzer
chmod 777 *
sh generacert.sh
```

## ▶️ Uso básico

```bash
sh fuzzer.sh URL
```

El script prueba combinaciones de rutas contra el servidor objetivo usando un diccionario de palabras comunes y clasifica las respuestas (200, 403, 500, etc.).

---

## 🗂️ Scripts incluidos

### Fuzzing de directorios y ficheros

| Script | Descripción |
|---|---|
| `fuzzer.sh` / `fuzzer0.sh` … `fuzzer9.sh` | Variantes del fuzzer principal de rutas |
| `fuzzerauto.sh`, `fuzzerauto1.sh`, `fuzzerauto2.sh` | Versiones automatizadas del fuzzing |
| `fuzzerfichero.sh`, `fuzzerfichero2.sh` | Fuzzing enfocado en ficheros específicos |
| `fuzzernmap.sh`, `fuzzernmap2.sh` | Integración del fuzzer con Nmap |
| `dirb.sh` | Fuzzing de directorios (basado en Dirb) |
| `directorios.sh`, `directorios1.sh`, `directorios2.sh` | Escaneo de directorios comunes |
| `explorarweb.sh`, `probarweb.sh` | Exploración/pruebas generales sobre el sitio web |
| `buscasecretos.sh` | Búsqueda de ficheros/secretos sensibles expuestos |

### Bypass de 403 / 40x

| Script | Descripción |
|---|---|
| `403bypass.py` / `403bypass.sh` … `403bypass9.sh` | Distintas variantes para intentar evadir un 403 Forbidden |
| `40xbypass.sh` | Bypass genérico de códigos 40x |
| `wafbypass.sh`, `wafbypass2.sh` | Intentos de evasión de WAF |
| `metodotrace.sh` | Pruebas con el método HTTP TRACE |

### Reconocimiento y utilidades HTTP

| Script | Descripción |
|---|---|
| `httpx_instalar.sh` | Instalación de la herramienta httpx |
| `httpx_code.sh` | Consulta de códigos de respuesta HTTP con httpx |
| `httpx_servidor_info.sh` | Información del servidor vía httpx |
| `httpx_subdominio.sh` | Enumeración de subdominios con httpx |
| `as2http.sh` | Conversión/pruebas de AS a HTTP |
| `generacert.sh` | Genera certificado necesario para la instalación |
| `instalar.sh`, `actualizar.sh` | Instalación y actualización del proyecto |

### Recursos de referencia

| Fichero | Contenido |
|---|---|
| `Codigos_respuesta_http.txt` | Listado de códigos de respuesta HTTP |
| `HTTP_codigos.jpg`, `codigoshttp.png` | Tablas visuales de códigos HTTP |
| `403.jpg` | Imagen de referencia sobre error 403 |
| `headers.txt` | Cabeceras HTTP de referencia |

---

## 📡 Códigos de respuesta HTTP relevantes

| Código | Significado | Interpretación en el fuzzing |
|---|---|---|
| `200 OK` | Recurso encontrado y accesible | Ruta válida y visible |
| `403 Forbidden` | Recurso existe pero acceso denegado | Candidato para bypass |
| `500 Internal Server Error` | Error del servidor | Puede indicar comportamiento anómalo explotable |

*(Ver `Codigos_respuesta_http.txt` para el listado completo de códigos HTTP.)*

---

## 🛡️ Bypass de 403 Forbidden

Los scripts `403bypass*` prueban cabeceras HTTP que simulan que la petición proviene del propio host (localhost / 127.0.0.1), una técnica habitual para intentar evadir restricciones de acceso mal configuradas.

| Categoría | Cabeceras probadas |
|---|---|
| Client / Real IP | `Client-IP`, `True-Client-IP`, `X-Client-IP`, `X-Real-IP`, `X-Remote-IP`, `X-Remote-Addr` |
| Forwarded (estándar y variantes) | `Forwarded`, `Forwarded-For`, `Forwarded-For-Ip`, `X-Forward`, `X-Forward-For`, `X-Forwarded`, `X-Forwarded-For`, `X-Forwarded-For-Original`, `X-Forwarded-By`, `X-Forwarded-Server`, `X-Forwared-Host` |
| Host / Originating | `X-Host`, `X-HTTP-Host-Override`, `X-Originating-IP` |
| Autorización personalizada | `X-Custom-IP-Authorization` |


## 🔗 Enlaces

- Sitio del proyecto: [www.hackingyseguridad.com](http://www.hackingyseguridad.com/)
- Repositorio: [github.com/hackingyseguridad/fuzzer](https://github.com/hackingyseguridad/fuzzer)
- Licencia: [GPL-3.0](https://github.com/hackingyseguridad/fuzzer/blob/master/LICENSE)
