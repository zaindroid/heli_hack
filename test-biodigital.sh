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

# Function to open in browser
open_browser() {
    local file_url="$1"

    # Try wslview first (WSL specific)
    if command -v wslview > /dev/null 2>&1; then
        echo "Using wslview (WSL)..."
        wslview "$file_url" 2>/dev/null && return 0
    fi

    # Try xdg-open (Linux)
    if command -v xdg-open > /dev/null 2>&1; then
        echo "Using xdg-open..."
        xdg-open "$file_url" 2>/dev/null && return 0
    fi

    # Try open (macOS)
    if command -v open > /dev/null 2>&1; then
        echo "Using open (macOS)..."
        open "$file_url" && return 0
    fi

    return 1
}

# Check if running in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Detected WSL environment"
    echo ""

    # Convert Linux path to Windows path
    if command -v wslpath > /dev/null 2>&1; then
        WINDOWS_PATH=$(wslpath -w "$TEST_FILE")
        echo "Windows path: $WINDOWS_PATH"
        echo ""

        # Try to open with Windows browser
        if command -v cmd.exe > /dev/null 2>&1; then
            echo "Opening in Windows browser..."
            cmd.exe /c start "" "$WINDOWS_PATH" 2>/dev/null
            OPENED=$?
        elif command -v wslview > /dev/null 2>&1; then
            echo "Opening with wslview..."
            wslview "$TEST_FILE"
            OPENED=$?
        else
            echo "Could not find a way to open browser from WSL."
            echo ""
            echo "Please manually open this file in Windows:"
            echo "$WINDOWS_PATH"
            echo ""
            echo "Or copy this path and paste it in your browser's address bar."
            exit 0
        fi
    else
        echo "Warning: wslpath command not found"
        echo ""
        echo "Manual steps:"
        echo "1. Open Windows File Explorer"
        echo "2. Navigate to: \\\\wsl\$\\Ubuntu\\home\\$(whoami)\\elr_hack\\heli_hack"
        echo "3. Double-click test-biodigital.html"
        exit 0
    fi
else
    # Not WSL, use standard methods
    open_browser "$TEST_FILE"
    OPENED=$?
fi

if [ $OPENED -ne 0 ]; then
    echo ""
    echo "Could not open browser automatically."
    echo ""

    if grep -qi microsoft /proc/version 2>/dev/null; then
        # WSL - show Windows path
        if command -v wslpath > /dev/null 2>&1; then
            WINDOWS_PATH=$(wslpath -w "$TEST_FILE")
            echo "Please manually open this file:"
            echo "$WINDOWS_PATH"
        else
            echo "Please navigate to this folder in Windows File Explorer:"
            echo "\\\\wsl\$\\Ubuntu\\home\\$(whoami)\\elr_hack\\heli_hack"
            echo "Then double-click: test-biodigital.html"
        fi
    else
        # Linux/Mac - show file:// URL
        echo "Please open this URL in your browser:"
        echo "file://$TEST_FILE"
    fi
fi

echo ""
echo "=========================================="
echo ""
echo "What the test will check:"
echo "  1. ✓ Internet connection"
echo "  2. ✓ Access to human.biodigital.com"
echo "  3. ✓ HumanAPI script loading"
echo "  4. ✓ API key validation"
echo "  5. ✓ 3D model loading"
echo ""
echo "The test page will show detailed results for each step."
echo ""
echo "If you see an error, the test will tell you:"
echo "  • What went wrong"
echo "  • Why it happened"
echo "  • How to fix it"
echo ""
echo "=========================================="
