#!/bin/bash

# HTTPS server for BioDigital testing with self-signed certificate

PORT=8443

echo "======================================"
echo "🔒 Starting Local HTTPS Test Server"
echo "======================================"
echo ""

# Create self-signed certificate if it doesn't exist
if [ ! -f "server.pem" ]; then
    echo "📜 Generating self-signed SSL certificate..."
    openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes \
        -subj "/C=US/ST=State/L=City/O=Development/CN=localhost" 2>/dev/null
    echo "✓ Certificate created"
    echo ""
fi

echo "Serving test-biodigital.html at:"
echo "  https://localhost:$PORT/test-biodigital.html"
echo ""
echo "⚠️  You'll see a security warning (self-signed cert)"
echo "    Click 'Advanced' → 'Proceed to localhost' to continue"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Create a simple Python HTTPS server
python3 - <<'PYTHON_SCRIPT'
import http.server
import ssl
import os

PORT = 8443
os.chdir(os.path.dirname(os.path.abspath(__file__)))

server_address = ('', PORT)
httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)

# Wrap the socket with SSL
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('server.pem')
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"Server running on https://localhost:{PORT}")
httpd.serve_forever()
PYTHON_SCRIPT
