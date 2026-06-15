#!/usr/bin/env python3
import http.server
import os
import socketserver

PORT = 8888
DIRECTORY = "dashboard"

os.chdir(DIRECTORY)

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    print(f"Dashboard ready → open http://localhost:{PORT} in your browser")
    httpd.serve_forever()
