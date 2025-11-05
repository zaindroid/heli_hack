#!/bin/bash

# HealthChat AI - Local Setup Script for Linux/Mac
# This script sets up the entire project for local development

set -e  # Exit on any error

echo "=========================================="
echo "   HealthChat AI - Setup Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print colored message
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Step 1: Check Prerequisites
echo "Step 1: Checking prerequisites..."
echo ""

# Check Python
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_status "Python 3 found: $PYTHON_VERSION"
else
    print_error "Python 3 is not installed. Please install Python 3.11 or higher."
    exit 1
fi

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    print_status "Node.js found: $NODE_VERSION"
else
    print_error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    print_status "npm found: $NPM_VERSION"
else
    print_error "npm is not installed."
    exit 1
fi

echo ""

# Step 2: Backend Setup
echo "Step 2: Setting up backend..."
echo ""

cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    print_status "Creating Python virtual environment..."
    python3 -m venv venv
else
    print_status "Virtual environment already exists"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip --quiet

# Install dependencies
print_status "Installing Python dependencies..."
pip install -r requirements.txt --quiet

print_status "Backend setup complete!"
echo ""

cd ..

# Step 3: Frontend Setup
echo "Step 3: Setting up frontend..."
echo ""

cd frontend

# Install npm dependencies
if [ ! -d "node_modules" ]; then
    print_status "Installing npm dependencies..."
    npm install --silent
else
    print_status "npm dependencies already installed, updating..."
    npm install --silent
fi

print_status "Frontend setup complete!"
echo ""

cd ..

# Step 4: Check environment files
echo "Step 4: Checking environment configuration..."
echo ""

if [ -f "backend/.env" ]; then
    print_status "Backend .env file found"
else
    print_warning "Backend .env file not found!"
    echo "Creating template .env file..."
    cat > backend/.env << EOF
# API Keys
DEEPGRAM_API_KEY=your_deepgram_key_here
BIODIGITAL_API_KEY=your_biodigital_key_here
OPENAI_API_KEY=your_openai_key_here

# Server Configuration
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
EOF
    print_warning "Please update backend/.env with your API keys"
fi

if [ -f "frontend/.env" ]; then
    print_status "Frontend .env file found"
else
    print_warning "Frontend .env file not found!"
    echo "Creating template .env file..."
    cat > frontend/.env << EOF
# Frontend Environment Variables
VITE_API_URL=http://localhost:8000
VITE_BIODIGITAL_API_KEY=your_biodigital_key_here
VITE_WS_URL=ws://localhost:8000
EOF
    print_warning "Please update frontend/.env with your API keys"
fi

echo ""

# Step 5: Create uploads directory
echo "Step 5: Creating necessary directories..."
mkdir -p backend/uploads
print_status "Created uploads directory"
echo ""

# Final message
echo "=========================================="
echo "   Setup Complete! 🎉"
echo "=========================================="
echo ""
echo "To start the application, run:"
echo ""
echo "  ${GREEN}./start.sh${NC}     # Start both frontend and backend"
echo ""
echo "Or manually:"
echo ""
echo "  Terminal 1 (Backend):"
echo "    cd backend"
echo "    source venv/bin/activate"
echo "    python -m app.main"
echo ""
echo "  Terminal 2 (Frontend):"
echo "    cd frontend"
echo "    npm run dev"
echo ""
echo "Then visit: ${GREEN}http://localhost:5173${NC}"
echo ""
echo "=========================================="
