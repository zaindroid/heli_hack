@echo off
REM HealthChat AI - Local Setup Script for Windows
REM This script sets up the entire project for local development

echo ==========================================
echo    HealthChat AI - Setup Script
echo ==========================================
echo.

REM Step 1: Check Prerequisites
echo Step 1: Checking prerequisites...
echo.

REM Check Python
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] Python is not installed. Please install Python 3.11 or higher.
    pause
    exit /b 1
) else (
    python --version
    echo [*] Python found
)

REM Check Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] Node.js is not installed. Please install Node.js 18 or higher.
    pause
    exit /b 1
) else (
    node --version
    echo [*] Node.js found
)

REM Check npm
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] npm is not installed.
    pause
    exit /b 1
) else (
    npm --version
    echo [*] npm found
)

echo.

REM Step 2: Backend Setup
echo Step 2: Setting up backend...
echo.

cd backend

REM Create virtual environment
if not exist "venv" (
    echo [*] Creating Python virtual environment...
    python -m venv venv
) else (
    echo [*] Virtual environment already exists
)

REM Activate virtual environment
echo [*] Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo [*] Upgrading pip...
python -m pip install --upgrade pip --quiet

REM Install dependencies
echo [*] Installing Python dependencies...
pip install -r requirements.txt --quiet

echo [*] Backend setup complete!
echo.

cd ..

REM Step 3: Frontend Setup
echo Step 3: Setting up frontend...
echo.

cd frontend

REM Install npm dependencies
if not exist "node_modules" (
    echo [*] Installing npm dependencies...
    call npm install --silent
) else (
    echo [*] npm dependencies already installed, updating...
    call npm install --silent
)

echo [*] Frontend setup complete!
echo.

cd ..

REM Step 4: Check environment files
echo Step 4: Checking environment configuration...
echo.

if exist "backend\.env" (
    echo [*] Backend .env file found
) else (
    echo [!] Backend .env file not found!
    echo Creating template .env file...
    (
        echo # API Keys
        echo DEEPGRAM_API_KEY=your_deepgram_key_here
        echo BIODIGITAL_API_KEY=your_biodigital_key_here
        echo OPENAI_API_KEY=your_openai_key_here
        echo.
        echo # Server Configuration
        echo HOST=0.0.0.0
        echo PORT=8000
        echo CORS_ORIGINS=http://localhost:5173,http://localhost:3000
    ) > backend\.env
    echo [!] Please update backend\.env with your API keys
)

if exist "frontend\.env" (
    echo [*] Frontend .env file found
) else (
    echo [!] Frontend .env file not found!
    echo Creating template .env file...
    (
        echo # Frontend Environment Variables
        echo VITE_API_URL=http://localhost:8000
        echo VITE_BIODIGITAL_API_KEY=your_biodigital_key_here
        echo VITE_WS_URL=ws://localhost:8000
    ) > frontend\.env
    echo [!] Please update frontend\.env with your API keys
)

echo.

REM Step 5: Create uploads directory
echo Step 5: Creating necessary directories...
if not exist "backend\uploads" mkdir backend\uploads
echo [*] Created uploads directory
echo.

REM Final message
echo ==========================================
echo    Setup Complete! 🎉
echo ==========================================
echo.
echo To start the application, run:
echo.
echo   start.bat     # Start both frontend and backend
echo.
echo Or manually:
echo.
echo   Terminal 1 (Backend):
echo     cd backend
echo     venv\Scripts\activate
echo     python -m app.main
echo.
echo   Terminal 2 (Frontend):
echo     cd frontend
echo     npm run dev
echo.
echo Then visit: http://localhost:5173
echo.
echo ==========================================
pause
