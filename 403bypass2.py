#!/usr/bin/env python3
"""
bypass 403/401
Autor: hackingyseguridad.com (2026)
Versión: 2.1 - Con comandos curl
"""

import requests
import argparse
from urllib.parse import urlparse, urljoin, quote
import random
import time
import sys
import os

# Configuración global
requests.packages.urllib3.disable_warnings()
TIMEOUT = 10

class Bypass403:
    def __init__(self, url, proxy=None, headers_file=None, verbose=False, output=None):
        self.url = url
        self.parsed_url = urlparse(url)
        self.base_url = f"{self.parsed_url.scheme}://{self.parsed_url.netloc}"
        self.path = self.parsed_url.path
        self.verbose = verbose
        self.output_file = output
        
        # Headers base
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        }
        
        # Configurar proxy
        self.proxies = {}
        if proxy:
            self.proxies = {'http': proxy, 'https': proxy}
    
    def generate_curl_command(self, method, url, headers=None):
        """Generar comando curl completo"""
        curl_cmd = f"curl -X {method} '{url}'"
        
        if headers:
            for key, value in headers.items():
                # Escapar comillas
                escaped_value = str(value).replace("'", "'\"'\"'")
                curl_cmd += f" -H '{key}: {escaped_value}'"
        
        curl_cmd += " --insecure --connect-timeout 10"
        
        if self.proxies:
            proxy_url = list(self.proxies.values())[0]
            curl_cmd += f" --proxy '{proxy_url}'"
        
        curl_cmd += " -i"
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
        except Exception as e:
            if self.verbose:
                print(f"[!] Error: {e}")
            return None
    
    def test_and_report(self, technique, url, method="GET", headers=None):
        """Ejecutar test y mostrar resultados"""
        response = self.test_request(url, method, headers)
        
        if response:
            status = response.status_code
            length = len(response.content)
            
            # Generar comando curl
            curl_cmd = self.generate_curl_command(method, url, headers)
            
            # Mostrar resultados interesantes
            if status not in [403, 401, 404, 400, 500] and status < 500:
                print(f"\n[✓] {technique}")
                print(f"    URL: {url}")
                print(f"    Status: {status} | Length: {length}")
                print(f"\n    Comando CURL:")
                print(f"    {curl_cmd}")
                print("    " + "-"*50)
                return True, curl_cmd
            
            elif self.verbose:
                print(f"[i] {technique} - Status: {status}")
        
        return False, None
    
    def test_header_bypasses(self):
        """Probar bypass con headers"""
        print("\n[1/9] Probando bypass con Headers HTTP...")
        techniques = []
        curl_commands = []
        
        # Headers comunes
        header_tests = [
            ("X-Original-URL", self.path, {'X-Original-URL': self.path}),
            ("X-Rewrite-URL", self.path, {'X-Rewrite-URL': self.path}),
            ("X-Forwarded-For 127.0.0.1", self.url, {'X-Forwarded-For': '127.0.0.1'}),
            ("X-Forwarded-For localhost", self.url, {'X-Forwarded-For': 'localhost'}),
            ("Referer", self.url, {'Referer': self.base_url}),
            ("Host localhost", self.url, {'Host': 'localhost'}),
            ("X-Forwarded-Host localhost", self.url, {'X-Forwarded-Host': 'localhost'}),
            ("X-Custom-IP-Authorization", self.url, {'X-Custom-IP-Authorization': '127.0.0.1'}),
        ]
        
        for name, endpoint, headers in header_tests:
            test_url = urljoin(self.base_url, endpoint) if endpoint.startswith('/') else endpoint
            success, curl_cmd = self.test_and_report(name, test_url, "GET", headers)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_url_manipulation(self):
        """Probar manipulación de URLs"""
        print("\n[2/9] Probando manipulación de URLs...")
        techniques = []
        curl_commands = []
        
        # Variaciones de URL
        url_tests = [
            ("URL Encoding", self.base_url + quote(self.path, safe='')),
            ("Double Encoding", self.base_url + quote(quote(self.path, safe=''), safe='')),
            (f"{self.path}/.", self.base_url + f"{self.path}/."),
            (f"{self.path}..", self.base_url + f"{self.path}.."),
            (f"//{self.path.lstrip('/')}", self.base_url + f"//{self.path.lstrip('/')}"),
            (f"{self.path};", self.base_url + f"{self.path};"),
            (f"{self.path}%20", self.base_url + f"{self.path}%20"),
            (f"{self.path}../", self.base_url + f"{self.path}../"),
            (f"{self.path}?", self.base_url + f"{self.path}?"),
            (f"{self.path}#", self.base_url + f"{self.path}#"),
        ]
        
        for name, test_url in url_tests:
            success, curl_cmd = self.test_and_report(name, test_url)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_http_methods(self):
        """Probar diferentes métodos HTTP"""
        print("\n[3/9] Probando diferentes métodos HTTP...")
        techniques = []
        curl_commands = []
        
        methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD', 'ACL', 'ARBITRARY','TRACE','PAHT']
        
        for method in methods:
            name = f"HTTP Method: {method}"
            success, curl_cmd = self.test_and_report(name, self.url, method)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_parameter_bypass(self):
        """Probar bypass con parámetros"""
        print("\n[4/9] Probando bypass con parámetros...")
        techniques = []
        curl_commands = []
        
        if '?' in self.url:
            base_url, params = self.url.split('?', 1)
            
            # Variaciones simples
            param_tests = [
                ("Add dummy param", f"{self.url}&dummy=1"),
                ("Change param order", f"{base_url}?{params[::-1][:10]}..."),
                ("URL encode params", f"{base_url}?{quote(params)}"),
            ]
            
            for name, test_url in param_tests:
                success, curl_cmd = self.test_and_report(name, test_url)
                if success and curl_cmd:
                    techniques.append(name)
                    curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_extension_fuzzing(self):
        """Probar diferentes extensiones"""
        print("\n[5/9] Probando diferentes extensiones...")
        techniques = []
        curl_commands = []
        
        if '.' in self.path:
            base_path = self.path.rsplit('.', 1)[0]
        else:
            base_path = self.path
        
        extensions = ['.html', '.php', '.json', '.txt', '.bak', '.old', '.tmp']
        
        for ext in extensions:
            test_url = self.base_url + base_path + ext
            name = f"Extension: {ext}"
            success, curl_cmd = self.test_and_report(name, test_url)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_protocol_port_bypass(self):
        """Probar diferentes puertos"""
        print("\n[6/9] Probando diferentes puertos...")
        techniques = []
        curl_commands = []
        
        host = self.parsed_url.netloc.split(':')[0] if ':' in self.parsed_url.netloc else self.parsed_url.netloc
        
        ports = ['80', '443', '8080', '8443', '8000']
        
        for port in ports[:2]:  # Solo probar 2 puertos para no saturar
            for proto in ['http', 'https']:
                test_url = f"{proto}://{host}:{port}{self.path}"
                name = f"{proto} port {port}"
                success, curl_cmd = self.test_and_report(name, test_url)
                if success and curl_cmd:
                    techniques.append(name)
                    curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_cookie_bypass(self):
        """Probar bypass con cookies"""
        print("\n[7/9] Probando bypass con Cookies...")
        techniques = []
        curl_commands = []
        
        cookies = [
            'admin=true',
            'authenticated=1',
            'logged_in=true',
            'user=admin',
        ]
        
        for cookie in cookies:
            headers = self.headers.copy()
            headers['Cookie'] = cookie
            name = f"Cookie: {cookie}"
            success, curl_cmd = self.test_and_report(name, self.url, "GET", headers)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_directory_fuzzing(self):
        """Probar directorios comunes"""
        print("\n[8/9] Probando directorios comunes...")
        techniques = []
        curl_commands = []
        
        dirs = ['/admin', '/dashboard', '/private', '/secret', '/api', '/v1', '/v2']
        
        for directory in dirs:
            test_url = self.base_url + directory
            name = f"Directory: {directory}"
            success, curl_cmd = self.test_and_report(name, test_url)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def test_cache_poisoning(self):
        """Probar cache poisoning"""
        print("\n[9/9] Probando técnicas de Cache Poisoning...")
        techniques = []
        curl_commands = []
        
        cache_tests = [
            ("X-Forwarded-Host evil.com", self.url, {'X-Forwarded-Host': 'evil.com'}),
            ("X-Original-URL root", '/', {'X-Original-URL': '/'}),
        ]
        
        for name, endpoint, headers in cache_tests:
            test_url = urljoin(self.base_url, endpoint) if endpoint.startswith('/') else endpoint
            success, curl_cmd = self.test_and_report(name, test_url, "GET", headers)
            if success and curl_cmd:
                techniques.append(name)
                curl_commands.append(curl_cmd)
        
        return techniques, curl_commands
    
    def run_all_tests(self):
        """Ejecutar todas las pruebas"""
        print(f"\n{'='*60}")
        print("BY403 - Herramienta de Bypass 403/401")
        print(f"{'='*60}")
        print(f"Target: {self.url}")
        print(f"Base URL: {self.base_url}")
        print(f"{'='*60}\n")
        
        all_techniques = []
        all_curl_commands = []
        
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
                techniques, curl_commands = test_func()
                all_techniques.extend(techniques)
                all_curl_commands.extend(curl_commands)
                time.sleep(0.5)
            except Exception as e:
                print(f"[!] Error en {test_func.__name__}: {e}")
        
        # Mostrar resumen
        self.show_summary(all_techniques, all_curl_commands)
    
    def show_summary(self, techniques, curl_commands):
        """Mostrar resumen"""
        print(f"\n{'='*60}")
        print("RESUMEN FINAL")
        print(f"{'='*60}")
        
        if techniques:
            print(f"\n[+] BYPASS ENCONTRADOS: {len(techniques)}")
            
            # Guardar comandos curl en archivo
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            curl_file = f"bypass_curl_{timestamp}.sh"
            
            with open(curl_file, 'w') as f:
                f.write("#!/bin/bash\n")
                f.write(f"# Comandos curl generados por BY403\n")
                f.write(f"# Target: {self.url}\n")
                f.write(f"# Fecha: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"# Total de bypass: {len(techniques)}\n\n")
                
                for i, (tech, curl_cmd) in enumerate(zip(techniques, curl_commands), 1):
                    print(f"\n[{i}] {tech}")
                    print(f"    {curl_cmd}")
                    
                    # Guardar en archivo
                    f.write(f"echo '\\n[{i}] {tech}'\n")
                    f.write(f"{curl_cmd}\n")
                    f.write("echo '----------------------------------------'\n")
                    f.write("sleep 1\n")
            
            print(f"\n{'='*60}")
            print(f"[+] Comandos curl guardados en: {curl_file}")
            print(f"[+] Ejecutar: chmod +x {curl_file} && ./{curl_file}")
            
            # También crear archivo de texto simple
            txt_file = f"bypass_commands_{timestamp}.txt"
            with open(txt_file, 'w') as f:
                for tech, curl_cmd in zip(techniques, curl_commands):
                    f.write(f"# {tech}\n")
                    f.write(f"{curl_cmd}\n\n")
            
            print(f"[+] Comandos simples en: {txt_file}")
        
        else:
            print(f"\n[!] No se encontraron bypass")
            print("[!] Prueba con --verbose para ver todas las respuestas")

def main():
    banner = """
╔══════════════════════════════════════════════╗
║           BYPASS 403/401 TOOL v2.1           ║
║        con comandos curl automáticos         ║
╚══════════════════════════════════════════════╝
"""
    print(banner)
    
    parser = argparse.ArgumentParser(description='Herramienta para bypass de 403/401')
    parser.add_argument('url', help='URL objetivo (ej: http://target.com/admin)')
    parser.add_argument('--proxy', help='Proxy (ej: http://127.0.0.1:8080)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Mostrar más información')
    parser.add_argument('--output', '-o', help='Archivo para guardar resultados')
    
    args = parser.parse_args()
    
    # Validar URL
    if not args.url.startswith(('http://', 'https://')):
        print("[!] Error: URL debe empezar con http:// o https://")
        sys.exit(1)
    
    # Crear y ejecutar herramienta
    tool = Bypass403(
        url=args.url,
        proxy=args.proxy,
        verbose=args.verbose,
        output=args.output
    )
    
    try:
        tool.run_all_tests()
    except KeyboardInterrupt:
        print("\n[!] Interrumpido por el usuario")
    except Exception as e:
        print(f"[!] Error: {e}")

if __name__ == "__main__":
    main()
