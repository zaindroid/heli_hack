# Troubleshooting Guide 🔧

Common issues and solutions for HealthChat AI.

## Setup Issues

### 1. Python Version Error

**Problem:** `Python 3.11 or higher required`

**Solution:**
```bash
# Check your Python version
python3 --version

# If too old, install Python 3.11+
# macOS with Homebrew:
brew install python@3.11

# Ubuntu/Debian:
sudo apt update
sudo apt install python3.11

# Windows: Download from python.org
```

### 2. Node.js Version Error

**Problem:** `Node.js 18 or higher required`

**Solution:**
```bash
# Check your Node.js version
node --version

# Install/update Node.js
# Using nvm (recommended):
nvm install 18
nvm use 18

# Or download from nodejs.org
```

### 3. Permission Denied on Shell Scripts

**Problem:** `Permission denied: ./setup.sh`

**Solution:**
```bash
chmod +x setup.sh start.sh
./setup.sh
```

### 4. Virtual Environment Creation Fails

**Problem:** `ERROR: Unable to create virtual environment`

**Solution:**
```bash
# Install python3-venv
# Ubuntu/Debian:
sudo apt install python3.11-venv

# Then try again
./setup.sh
```

## Runtime Issues

### 5. Backend Won't Start

**Problem:** Backend fails to start or crashes

**Solution:**

**Check Python dependencies:**
```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m app.main
```

**Check for port conflicts:**
```bash
# Port 8000 already in use?
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill the process or change port in backend/.env
```

**Check environment variables:**
```bash
# Verify .env file exists and has API keys
cat backend/.env

# Make sure keys are valid (no quotes, no spaces)
```

### 6. Frontend Won't Start

**Problem:** Frontend fails to build or start

**Solution:**

**Clear node_modules and reinstall:**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run dev
```

**Check for port conflicts:**
```bash
# Port 5173 already in use?
lsof -i :5173  # macOS/Linux
netstat -ano | findstr :5173  # Windows
```

### 7. BioDigital Human Not Loading

**Problem:** 3D viewer shows error or blank screen

**Solution:**

1. **Check API key:**
   - Verify `VITE_BIODIGITAL_API_KEY` in `frontend/.env`
   - No quotes around the key
   - No extra spaces

2. **Check browser console:**
   - Open DevTools (F12)
   - Look for errors in Console tab
   - Check Network tab for failed requests

3. **Test API key:**
   - Visit: https://human.biodigital.com/
   - Try to load a model with your API key

4. **CORS issues:**
   - Make sure backend CORS is configured correctly
   - Check `backend/.env` CORS_ORIGINS includes `http://localhost:5173`

### 8. WebSocket Connection Failed

**Problem:** Voice interface shows "Connection Error"

**Solution:**

1. **Check backend is running:**
   ```bash
   curl http://localhost:8000/api/health
   ```

2. **Check WebSocket endpoint:**
   - Backend should show: `WebSocket endpoint available at ws://localhost:8000/ws/voice`

3. **Verify .env settings:**
   - `frontend/.env` should have: `VITE_WS_URL=ws://localhost:8000`

4. **Check browser console:**
   - Look for WebSocket connection errors
   - Check if it's trying to connect to the right URL

### 9. OpenAI API Errors

**Problem:** AI responses fail or timeout

**Solution:**

1. **Check API key:**
   - Verify `OPENAI_API_KEY` in `backend/.env`
   - Test key: https://platform.openai.com/api-keys

2. **Check API quota:**
   - Visit: https://platform.openai.com/usage
   - Make sure you have credits

3. **Check model availability:**
   - Current model: `gpt-4-turbo-preview`
   - May need to change to `gpt-3.5-turbo` if no GPT-4 access

4. **Update model in code:**
   ```python
   # In backend/app/pipecat_agent.py line 119
   model="gpt-3.5-turbo",  # Change from gpt-4-turbo-preview
   ```

### 10. File Upload Fails

**Problem:** Cannot upload medical reports

**Solution:**

1. **Check uploads directory exists:**
   ```bash
   mkdir -p backend/uploads
   chmod 755 backend/uploads
   ```

2. **Check file size limits:**
   - Default limit: ~10MB
   - Increase in `backend/app/main.py` if needed

3. **Check file type:**
   - Supported: PDF, JPG, PNG
   - Check MIME type is correct

### 11. Tesseract OCR Not Found

**Problem:** `TesseractNotFoundError` when processing images

**Solution:**

**Install Tesseract OCR:**

```bash
# macOS:
brew install tesseract

# Ubuntu/Debian:
sudo apt install tesseract-ocr

# Windows:
# Download installer from:
# https://github.com/UB-Mannheim/tesseract/wiki
```

Then reinstall Python dependencies:
```bash
cd backend
source venv/bin/activate
pip install pytesseract
```

## Docker Issues

### 12. Docker Compose Fails

**Problem:** `docker-compose up` fails

**Solution:**

1. **Check Docker is running:**
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Rebuild containers:**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up
   ```

3. **Check logs:**
   ```bash
   docker-compose logs backend
   docker-compose logs frontend
   ```

4. **Remove old containers:**
   ```bash
   docker-compose down -v
   docker system prune -a
   ```

## API Key Issues

### 13. Invalid or Missing API Keys

**Problem:** Services fail due to missing/invalid keys

**Solution:**

1. **Get all required API keys:**
   - **Deepgram**: https://console.deepgram.com/signup
   - **BioDigital**: https://human.biodigital.com/developers
   - **OpenAI**: https://platform.openai.com/api-keys

2. **Update .env files:**
   ```bash
   # backend/.env
   DEEPGRAM_API_KEY=your_actual_key_here
   BIODIGITAL_API_KEY=your_actual_key_here
   OPENAI_API_KEY=your_actual_key_here

   # frontend/.env
   VITE_BIODIGITAL_API_KEY=your_actual_key_here
   ```

3. **No quotes or spaces:**
   ```bash
   # WRONG:
   OPENAI_API_KEY = "sk-..."

   # CORRECT:
   OPENAI_API_KEY=sk-...
   ```

4. **Restart services** after updating keys

## Performance Issues

### 14. Slow Response Times

**Problem:** AI takes too long to respond

**Solutions:**

1. **Use faster model:**
   - Change from `gpt-4-turbo-preview` to `gpt-3.5-turbo`

2. **Reduce max_tokens:**
   - In `backend/app/pipecat_agent.py`, reduce `max_tokens=500` to `200`

3. **Check internet connection:**
   - All APIs require stable internet
   - Test: `ping api.openai.com`

### 15. High Memory Usage

**Problem:** System running out of memory

**Solutions:**

1. **Close unused applications**

2. **Reduce concurrent requests:**
   - Don't upload multiple large files at once

3. **Increase swap space** (Linux):
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

## Still Having Issues?

### Check Logs

**Backend logs:**
```bash
cd backend
source venv/bin/activate
python -m app.main
# Watch the console output
```

**Frontend logs:**
```bash
cd frontend
npm run dev
# Watch the console output
# Also check browser DevTools Console (F12)
```

### Health Check

Test all endpoints:

```bash
# Backend health
curl http://localhost:8000/api/health

# Should return:
# {
#   "status": "healthy",
#   "deepgram": "configured",
#   "openai": "configured",
#   "biodigital": "configured"
# }
```

### Reset Everything

**Nuclear option - fresh start:**

```bash
# Stop all services
pkill -f "python -m app.main"
pkill -f "npm run dev"

# Clean everything
rm -rf backend/venv backend/__pycache__ backend/uploads/*
rm -rf frontend/node_modules frontend/dist

# Start fresh
./setup.sh
./start.sh
```

## Get Help

If you're still stuck:

1. **Check backend logs** for error messages
2. **Check browser console** (F12) for frontend errors
3. **Verify all API keys** are valid and have credits
4. **Test internet connection** to API services
5. **Check system requirements** are met

### System Requirements

**Minimum:**
- Python 3.11+
- Node.js 18+
- 4GB RAM
- 2GB free disk space
- Stable internet connection

**Recommended:**
- Python 3.11+
- Node.js 20+
- 8GB RAM
- 5GB free disk space
- High-speed internet

---

**Need more help?** Check the main [README.md](README.md) for detailed setup instructions.
