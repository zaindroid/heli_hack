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
CYAN='\033[0;36m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Spinner function for long-running operations
spinner() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    echo -n "$message "
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${NC}]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))

    printf "\r${CYAN}Progress:${NC} ["
    printf "%${completed}s" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] ${BLUE}%3d%%${NC}" $percentage
}

# Run command with live output and spinner
run_with_progress() {
    local message=$1
    local command=$2
    local logfile="/tmp/healthchat_setup_$$.log"

    echo -e "${CYAN}▶${NC} $message"

    # Run command in background
    eval "$command" > "$logfile" 2>&1 &
    local pid=$!

    # Show spinner with dots
    local dots=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r  ${CYAN}[%s]${NC} Working%s" "$(date +%T)" "$(printf '.%.0s' $(seq 1 $((dots % 4))))"
        printf "   "
        sleep 0.5
        dots=$((dots + 1))
    done

    # Check if command succeeded
    wait $pid
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} Complete!                    \n"
        rm -f "$logfile"
        return 0
    else
        printf "\r  ${RED}✗${NC} Failed!                      \n"
        echo ""
        echo -e "${RED}Error details:${NC}"
        cat "$logfile"
        rm -f "$logfile"
        return 1
    fi
}

# Step 1: Check Prerequisites
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1/5:${NC} Checking prerequisites..."
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

# Step 1.5: Install System Dependencies (for WSL/Ubuntu/Debian)
if [ -f /etc/debian_version ] || grep -qi microsoft /proc/version 2>/dev/null; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Step 1.5/5:${NC} Installing system dependencies for WSL/Ubuntu..."
    echo ""

    print_status "Detected Debian-based system (Ubuntu/WSL)"

    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        print_warning "Some system dependencies require sudo access"
        print_info "Please enter your password if prompted..."
        echo ""

        # Update package list with progress
        run_with_progress "Updating package lists..." "sudo apt-get update -qq"

        # Install dependencies with progress
        print_info "Installing system packages (this may take 2-3 minutes)..."
        echo ""

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
            libglib2.0-0 2>&1 | while read line; do
            if [[ $line =~ "Setting up" ]]; then
                echo -e "  ${CYAN}→${NC} ${line}"
            fi
        done

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            echo ""
            print_status "System dependencies installed successfully"
        else
            print_warning "Some dependencies may have failed to install, but continuing..."
        fi
    else
        run_with_progress "Updating package lists..." "apt-get update -qq"
        run_with_progress "Installing system dependencies..." "apt-get install -y python3-dev python3-pip build-essential libjpeg-dev libpng-dev libtiff-dev libwebp-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libharfbuzz-dev libfribidi-dev libxcb1-dev tesseract-ocr libgl1-mesa-glx libglib2.0-0"
        print_status "System dependencies installed successfully"
    fi

    echo ""
fi

# Step 2: Backend Setup
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2/5:${NC} Setting up Python backend..."
echo ""

cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    run_with_progress "Creating Python virtual environment..." "python3 -m venv venv"
else
    print_status "Virtual environment already exists"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
run_with_progress "Upgrading pip..." "pip install --upgrade pip --quiet"

# Install dependencies with progress
print_info "Installing Python packages (this may take 3-5 minutes)..."
echo ""

# Count total packages
TOTAL_PACKAGES=$(grep -v '^#' requirements.txt | grep -v '^$' | wc -l)
CURRENT=0

# Install with progress output
pip install -r requirements.txt 2>&1 | while read line; do
    if [[ $line =~ "Collecting" ]] || [[ $line =~ "Downloading" ]] || [[ $line =~ "Installing collected packages" ]]; then
        CURRENT=$((CURRENT + 1))
        if [ $CURRENT -le $TOTAL_PACKAGES ]; then
            progress_bar $CURRENT $TOTAL_PACKAGES
        fi
    fi
    if [[ $line =~ "Successfully installed" ]]; then
        echo ""
        echo -e "  ${GREEN}✓${NC} ${line}"
    fi
done

echo ""
print_status "Backend setup complete!"
echo ""

cd ..

# Step 3: Frontend Setup
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3/5:${NC} Setting up React frontend..."
echo ""

cd frontend

# Install npm dependencies
if [ ! -d "node_modules" ]; then
    print_info "Installing npm packages (this may take 2-3 minutes)..."
    echo ""

    # Install with progress
    npm install 2>&1 | while read line; do
        if [[ $line =~ "added" ]] || [[ $line =~ "removed" ]] || [[ $line =~ "changed" ]]; then
            echo -e "  ${CYAN}→${NC} ${line}"
        fi
    done

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        print_status "npm packages installed successfully"
    fi
else
    print_status "npm dependencies already installed"

    # Check if update needed
    print_info "Checking for updates..."
    npm outdated > /dev/null 2>&1 || true
fi

print_status "Frontend setup complete!"
echo ""

cd ..

# Step 4: Check environment files
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4/5:${NC} Checking environment configuration..."
echo ""

if [ -f "backend/.env" ]; then
    print_status "Backend .env file found"
else
    print_warning "Backend .env file not found!"
    print_info "Creating template .env file..."
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
    print_info "Creating template .env file..."
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
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5/5:${NC} Creating necessary directories..."
echo ""

mkdir -p backend/uploads
print_status "Created uploads directory"
echo ""

# Final message
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   Setup Complete! 🎉${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo ""
echo -e "  ${GREEN}./start.sh${NC}     # Start both frontend and backend"
echo ""
echo -e "${CYAN}Or start manually:${NC}"
echo ""
echo "  Terminal 1 (Backend):"
echo -e "    ${YELLOW}cd backend${NC}"
echo -e "    ${YELLOW}source venv/bin/activate${NC}"
echo -e "    ${YELLOW}python -m app.main${NC}"
echo ""
echo "  Terminal 2 (Frontend):"
echo -e "    ${YELLOW}cd frontend${NC}"
echo -e "    ${YELLOW}npm run dev${NC}"
echo ""
echo -e "${CYAN}Then visit:${NC} ${GREEN}http://localhost:5173${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
