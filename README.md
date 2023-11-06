# fuzzer http y https

Descubre ficheros interesantes en  url de sitio web por respuestas:

HTTP/1.1 200 OK..
HTTP/1.1 403 OK
HTTP/1.1 500 OK

Instalación:

git clone https://github.com/hackingyseguridad/fuzzer

cd fuzzer

chmod 777 *

sh generacert.sh

Uso.: 

#sh fuzzer.sh URL


Respuestas HTTP:

        '200':
          description: OK
        '204':
          description: No content
        '400':
          description: Bad request
        '401':
          description: Unauthorized
        '403':
          description: Forbidden
        '404':
          description: Not found
        '409':
          description: Conflict
        '500':
          description: inernal server error
        '503':
          description: Service unavailable


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



www.hackingyseguridad.com
