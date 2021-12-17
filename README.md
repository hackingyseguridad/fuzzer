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


www.hackingyseguridad.com
