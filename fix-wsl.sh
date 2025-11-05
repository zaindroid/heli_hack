#!/bin/bash

# Quick fix script for Python 3.13 / Pillow compatibility issues on WSL
# This installs system dependencies needed for Pillow and OpenCV

echo "=========================================="
echo "   HealthChat AI - WSL Dependency Fix"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

echo "Installing system dependencies for Pillow, OpenCV, and Tesseract..."
echo ""

print_warning "This requires sudo access. Please enter your password if prompted."
echo ""

# Update package list
sudo apt-get update -qq

# Install dependencies
sudo apt-get install -y \
    python3-dev \
    python3-pip \
    build-essential \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    libopenjp2-7-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    tesseract-ocr \
    libgl1-mesa-glx \
    libglib2.0-0

if [ $? -eq 0 ]; then
    print_status "System dependencies installed successfully!"
    echo ""
    echo "Now run the setup script again:"
    echo ""
    echo "  ./setup.sh"
    echo ""
else
    echo "Some dependencies failed to install. Please check the errors above."
    exit 1
fi

echo "=========================================="
