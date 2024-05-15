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

<img style="float:left" alt="Codigos HTTP" src="https://github.com/hackingyseguridad/fuzzer/blob/main/HTTP_codigos.jpg">

you can run fuzzer.sh by pointing it to the URL of the web application you want to test. For example, to test the web application at http://example.com, you would run the following command:

fuzzer.sh http://example.com
Fuzzer.sh will then generate random input and send it to the web application. If the web application is vulnerable, the fuzzer may be able to crash the application or exploit a vulnerability.

Fuzzer.sh can be a valuable tool for testing the security of web applications. However, it is important to note that fuzzer.sh is not a silver bullet. It is not guaranteed to find all vulnerabilities, and it can also generate false positives. It is important to use fuzzer.sh in conjunction with other security testing tools and methods.



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
