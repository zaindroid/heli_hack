@echo off
REM HealthChat AI - Local Setup Script for Windows
REM This script sets up the entire project for local development

setlocal EnableDelayedExpansion

echo ==========================================
echo    HealthChat AI - Setup Script
echo ==========================================
echo.

REM Colors for Windows (using findstr for basic coloring)
set "GREEN=[92m"
set "YELLOW=[93m"
set "CYAN=[96m"
set "BLUE=[94m"
set "RED=[91m"
set "NC=[0m"

REM Step 1: Check Prerequisites
echo.
echo ========================================
echo Step 1/5: Checking prerequisites...
echo ========================================
echo.

REM Check Python
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo %RED%[X]%NC% Python is not installed. Please install Python 3.11 or higher.
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%i in ('python --version') do set PYTHON_VER=%%i
    echo %GREEN%[*]%NC% Python found: !PYTHON_VER!
)

REM Check Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo %RED%[X]%NC% Node.js is not installed. Please install Node.js 18 or higher.
    pause
    exit /b 1
) else (
    for /f %%i in ('node --version') do set NODE_VER=%%i
    echo %GREEN%[*]%NC% Node.js found: !NODE_VER!
)

REM Check npm
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo %RED%[X]%NC% npm is not installed.
    pause
    exit /b 1
) else (
    for /f %%i in ('npm --version') do set NPM_VER=%%i
    echo %GREEN%[*]%NC% npm found: !NPM_VER!
)

echo.

REM Step 2: Backend Setup
echo.
echo ========================================
echo Step 2/5: Setting up Python backend...
echo ========================================
echo.

cd backend

REM Create virtual environment
if not exist "venv" (
    echo %CYAN%[*]%NC% Creating Python virtual environment...
    echo     [Please wait, this may take 1-2 minutes...]
    python -m venv venv
    if %ERRORLEVEL% EQU 0 (
        echo %GREEN%[*]%NC% Virtual environment created successfully!
    ) else (
        echo %RED%[X]%NC% Failed to create virtual environment
        pause
        exit /b 1
    )
) else (
    echo %GREEN%[*]%NC% Virtual environment already exists
)

REM Activate virtual environment
echo %CYAN%[*]%NC% Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo %CYAN%[*]%NC% Upgrading pip...
echo     [Please wait...]
python -m pip install --upgrade pip --quiet
if %ERRORLEVEL% EQU 0 (
    echo %GREEN%[*]%NC% pip upgraded successfully!
) else (
    echo %YELLOW%[!]%NC% pip upgrade had issues, continuing...
)

REM Install dependencies
echo.
echo %CYAN%[*]%NC% Installing Python packages (this may take 3-5 minutes)...
echo     [Installing dependencies from requirements.txt...]
echo.

REM Show package count
for /f %%i in ('findstr /R /N "^" requirements.txt ^| find /C ":"') do set PKG_COUNT=%%i
echo     Total packages to install: !PKG_COUNT!
echo.

REM Install with verbose output
pip install -r requirements.txt
if %ERRORLEVEL% EQU 0 (
    echo.
    echo %GREEN%[*]%NC% Backend setup complete!
) else (
    echo.
    echo %RED%[X]%NC% Failed to install Python dependencies
    echo     Check the error messages above
    pause
    exit /b 1
)

echo.

cd ..

REM Step 3: Frontend Setup
echo.
echo ========================================
echo Step 3/5: Setting up React frontend...
echo ========================================
echo.

cd frontend

REM Install npm dependencies
if not exist "node_modules" (
    echo %CYAN%[*]%NC% Installing npm packages (this may take 2-3 minutes)...
    echo     [This will download and install all dependencies...]
    echo.

    call npm install
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo %GREEN%[*]%NC% npm packages installed successfully!
    ) else (
        echo.
        echo %RED%[X]%NC% Failed to install npm dependencies
        pause
        exit /b 1
    )
) else (
    echo %GREEN%[*]%NC% npm dependencies already installed
    echo %CYAN%[*]%NC% Checking for updates...
    call npm outdated 2>nul
)

echo.
echo %GREEN%[*]%NC% Frontend setup complete!
echo.

cd ..

REM Step 4: Check environment files
echo.
echo ========================================
echo Step 4/5: Checking environment configuration...
echo ========================================
echo.

if exist "backend\.env" (
    echo %GREEN%[*]%NC% Backend .env file found
) else (
    echo %YELLOW%[!]%NC% Backend .env file not found!
    echo %CYAN%[*]%NC% Creating template .env file...
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
    echo %YELLOW%[!]%NC% Please update backend\.env with your API keys
)

if exist "frontend\.env" (
    echo %GREEN%[*]%NC% Frontend .env file found
) else (
    echo %YELLOW%[!]%NC% Frontend .env file not found!
    echo %CYAN%[*]%NC% Creating template .env file...
    (
        echo # Frontend Environment Variables
        echo VITE_API_URL=http://localhost:8000
        echo VITE_BIODIGITAL_API_KEY=your_biodigital_key_here
        echo VITE_WS_URL=ws://localhost:8000
    ) > frontend\.env
    echo %YELLOW%[!]%NC% Please update frontend\.env with your API keys
)

echo.

REM Step 5: Create uploads directory
echo.
echo ========================================
echo Step 5/5: Creating necessary directories...
echo ========================================
echo.

if not exist "backend\uploads" mkdir backend\uploads
echo %GREEN%[*]%NC% Created uploads directory
echo.

REM Final message
echo.
echo ==========================================
echo    Setup Complete! 🎉
echo ==========================================
echo.
echo %CYAN%Quick Start:%NC%
echo.
echo   %GREEN%start.bat%NC%     # Start both frontend and backend
echo.
echo %CYAN%Or start manually:%NC%
echo.
echo   Terminal 1 (Backend):
echo     %YELLOW%cd backend%NC%
echo     %YELLOW%venv\Scripts\activate%NC%
echo     %YELLOW%python -m app.main%NC%
echo.
echo   Terminal 2 (Frontend):
echo     %YELLOW%cd frontend%NC%
echo     %YELLOW%npm run dev%NC%
echo.
echo %CYAN%Then visit:%NC% %GREEN%http://localhost:5173%NC%
echo.
echo ==========================================
echo.
pause
