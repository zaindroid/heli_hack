@echo off
REM HealthChat AI - Start Script for Windows
REM This script starts both frontend and backend services

echo ==========================================
echo    HealthChat AI - Starting Services
echo ==========================================
echo.

REM Check if setup was run
if not exist "backend\venv" (
    echo [!] Virtual environment not found. Please run setup.bat first.
    pause
    exit /b 1
)

if not exist "frontend\node_modules" (
    echo [!] Node modules not found. Please run setup.bat first.
    pause
    exit /b 1
)

REM Start Backend in new window
echo [*] Starting Backend...
start "HealthChat Backend" cmd /k "cd backend && venv\Scripts\activate && python -m app.main"

echo [*] Backend started
echo     API: http://localhost:8000
echo     Docs: http://localhost:8000/docs
echo.

REM Wait a moment for backend to start
timeout /t 3 /nobreak >nul

REM Start Frontend in new window
echo [*] Starting Frontend...
start "HealthChat Frontend" cmd /k "cd frontend && npm run dev"

echo [*] Frontend started
echo     App: http://localhost:5173
echo.

echo ==========================================
echo    Services Running Successfully!
echo ==========================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo.
echo Two new windows have been opened.
echo Close those windows to stop the services.
echo.
echo ==========================================
echo.
echo Press any key to exit this window...
pause >nul
