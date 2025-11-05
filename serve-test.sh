#!/bin/bash

# Simple HTTP server to serve the test file
# BioDigital requires HTTPS, but let's try HTTP first to see if it works locally

PORT=8080

echo "======================================"
echo "🌐 Starting Local Test Server"
echo "======================================"
echo ""
echo "Serving test-biodigital.html at:"
echo "  http://localhost:$PORT/test-biodigital.html"
echo ""
echo "IMPORTANT: BioDigital requires HTTPS for production."
echo "If this doesn't work, we'll set up HTTPS with a self-signed cert."
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start Python HTTP server
cd "$(dirname "$0")"
python3 -m http.server $PORT
