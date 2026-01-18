

```
███████╗██╗   ██╗███████╗███████╗███████╗███████╗██████╗ 
██╔════╝██║   ██║╚══███╔╝╚══███╔╝██╔════╝██╔════╝██╔══██╗
█████╗  ██║   ██║  ███╔╝   ███╔╝ █████╗  █████╗  ██████╔╝
██╔══╝  ██║   ██║ ███╔╝   ███╔╝  ██╔══╝  ██╔══╝  ██╔══██╗
██║     ╚██████╔╝███████╗███████╗███████╗███████╗██║  ██║
╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
```

## fuzzer http y https

fuzzer para descubrir archivos/carpetas prueba combinaciones de rutas en un servidor web usando un diccionario de palabras comunes. Descubre ficheros interesantes en  url de sitio web por respuestas:

HTTP/1.1 200 OK..
HTTP/1.1 403 OK
HTTP/1.1 500 OK

### Instalación:

git clone https://github.com/hackingyseguridad/fuzzer

cd fuzzer

chmod 777 *

sh generacert.sh

Uso.: 

#sh fuzzer.sh URL

### Codigos de respuestas HTTP:

<img style="float:left" alt="Codigos HTTP" src="https://github.com/hackingyseguridad/fuzzer/blob/master/codigoshttp.png">

### 403 Forbidden - Bypass

- Scripts en Bash Shell, para probar fisuras a las capertas prohibidas , que devuelven un error 403 forbidden!, con X Cabeceras o similando ser la IP del propio host o de localhost, p.ej.:

X Cabeceras localhost:

Client-IP: 127.0.0.1

Forwarded-For-Ip: 127.0.0.1

Forwarded-For: 127.0.0.1

Forwarded-For: localhost

Forwarded: 127.0.0.1

Forwarded: localhost

True-Client-IP: 127.0.0.1

X-Client-IP: 127.0.0.1

X-Custom-IP-Authorization: 127.0.0.1

X-Forward-For: 127.0.0.1

X-Forward: 127.0.0.1

X-Forward: localhost

X-Forwarded-By: 127.0.0.1

X-Forwarded-By: localhost

X-Forwarded-For-Original: 127.0.0.1

X-Forwarded-For-Original: localhost

X-Forwarded-For: 127.0.0.1

X-Forwarded-For: localhost

X-Forwarded-Server: 127.0.0.1

X-Forwarded-Server: localhost

X-Forwarded: 127.0.0.1

X-Forwarded: localhost

X-Forwared-Host: 127.0.0.1

X-Forwared-Host: localhost

X-Host: 127.0.0.1

X-Host: localhost

X-HTTP-Host-Override: 127.0.0.1

X-Originating-IP: 127.0.0.1

X-Real-IP: 127.0.0.1

X-Remote-Addr: 127.0.0.1

X-Remote-Addr: localhost

X-Remote-IP: 127.0.0.1


#
http://www.hackingyseguridad.com/
#

