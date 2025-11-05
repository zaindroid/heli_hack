#!/bin/bash

# BioDigital API Test Script
# Opens the test page in your default browser

echo "=========================================="
echo "   BioDigital API Test"
echo "=========================================="
echo ""
echo "Opening test page in your browser..."
echo ""

# Get the full path to the HTML file
TEST_FILE="$(pwd)/test-biodigital.html"

# Check if file exists
if [ ! -f "$TEST_FILE" ]; then
    echo "Error: test-biodigital.html not found!"
    echo "Make sure you're in the heli_hack directory."
    exit 1
fi

# Open in browser based on OS
if command -v xdg-open > /dev/null 2>&1; then
    # Linux/WSL
    xdg-open "$TEST_FILE" 2>/dev/null || \
    wslview "$TEST_FILE" 2>/dev/null || \
    echo "Could not open browser automatically."
elif command -v open > /dev/null 2>&1; then
    # macOS
    open "$TEST_FILE"
else
    echo "Could not detect browser command."
fi

echo ""
echo "Test page URL: file://$TEST_FILE"
echo ""
echo "If the browser didn't open automatically, copy the URL above"
echo "and paste it into your browser's address bar."
echo ""
echo "=========================================="
echo ""
echo "What the test will check:"
echo "  1. Internet connection"
echo "  2. Access to human.biodigital.com"
echo "  3. HumanAPI script loading"
echo "  4. API key validation"
echo "  5. 3D model loading"
echo ""
echo "The test page will show detailed results for each step."
echo "=========================================="
