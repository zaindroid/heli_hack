#!/bin/bash

# HealthChat AI - Start Script for Linux/Mac
# This script starts both frontend and backend services

set -e

echo "=========================================="
echo "   HealthChat AI - Starting Services"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if setup was run
if [ ! -d "backend/venv" ]; then
    echo -e "${YELLOW}Virtual environment not found. Running setup...${NC}"
    ./setup.sh
fi

if [ ! -d "frontend/node_modules" ]; then
    echo -e "${YELLOW}Node modules not found. Running setup...${NC}"
    ./setup.sh
fi

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down services..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start Backend
echo -e "${CYAN}Starting Backend...${NC}"
cd backend
source venv/bin/activate
python -m app.main &
BACKEND_PID=$!
cd ..

echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
echo "  API: http://localhost:8000"
echo "  Docs: http://localhost:8000/docs"
echo ""

# Wait a moment for backend to start
sleep 3

# Start Frontend
echo -e "${CYAN}Starting Frontend...${NC}"
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
echo "  App: http://localhost:5173"
echo ""

echo "=========================================="
echo -e "${GREEN}   Services Running Successfully!${NC}"
echo "=========================================="
echo ""
echo "📱 Frontend: http://localhost:5173"
echo "🔧 Backend:  http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop all services"
echo "=========================================="
echo ""

# Wait for processes
wait $BACKEND_PID $FRONTEND_PID
