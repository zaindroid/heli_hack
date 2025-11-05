# WSL Setup Guide for HealthChat AI 🐧

Special instructions for Windows Subsystem for Linux (WSL) users.

## Quick Fix for Pillow/OpenCV Errors

If you're getting errors like:
```
ERROR: Failed to build 'pillow' when getting requirements to build wheel
KeyError: '__version__'
```

**Run this quick fix:**

```bash
./fix-wsl.sh
```

Then run setup again:
```bash
./setup.sh
```

---

## Complete WSL Setup Instructions

### Step 1: Install System Dependencies

Before running the main setup, install required system packages:

```bash
sudo apt-get update

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
```

**What these packages do:**
- `python3-dev` - Python header files for building C extensions
- `build-essential` - C/C++ compilers and build tools
- `libjpeg-dev`, `libpng-dev`, etc. - Image processing libraries for Pillow
- `tesseract-ocr` - OCR engine for reading medical reports
- `libgl1-mesa-glx`, `libglib2.0-0` - Required for OpenCV

### Step 2: Run Setup Script

The setup script will now auto-detect WSL and install dependencies:

```bash
./setup.sh
```

### Step 3: Start Services

```bash
./start.sh
```

---

## Python Version Compatibility

### Current Support:
- ✅ **Python 3.11** - Fully tested, recommended
- ✅ **Python 3.12** - Supported
- ⚠️ **Python 3.13** - Supported with updated packages

### If You Have Python 3.13:

The updated `requirements.txt` now includes Python 3.13-compatible versions:
- Pillow 11.0.0 (instead of 10.1.0)
- NumPy 2.1.3 (instead of 1.26.2)
- FastAPI 0.115.0 (latest stable)
- OpenAI 1.54.0 (latest)

If you still have issues, consider using Python 3.11:

```bash
# Install Python 3.11
sudo apt-get install python3.11 python3.11-venv

# Use Python 3.11 for the project
cd backend
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Common WSL Issues

### Issue 1: Permission Denied for Shell Scripts

**Problem:**
```bash
bash: ./setup.sh: Permission denied
```

**Solution:**
```bash
chmod +x setup.sh start.sh fix-wsl.sh
./setup.sh
```

### Issue 2: Slow npm install

**Problem:** npm install takes forever on WSL

**Solutions:**

1. **Disable Windows Defender real-time scanning for WSL:**
   - Open Windows Security
   - Virus & threat protection → Manage settings
   - Add exclusion for: `\\wsl$\Ubuntu\home\<your-username>\`

2. **Use faster npm registry:**
```bash
npm config set registry https://registry.npmjs.org/
npm cache clean --force
```

3. **Install in Linux filesystem (not /mnt/c/):**
```bash
# Clone to your Linux home directory
cd ~
git clone <repo-url>
cd heli_hack
```

### Issue 3: Network/API Issues

**Problem:** Cannot connect to APIs from WSL

**Solution:**

1. **Check internet connectivity:**
```bash
ping google.com
curl https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY"
```

2. **Configure WSL networking:**
```bash
# In /etc/wsl.conf
[network]
generateResolvConf = false

# Then set DNS manually in /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
```

3. **Restart WSL:**
```powershell
# In Windows PowerShell
wsl --shutdown
wsl
```

### Issue 4: Port Already in Use

**Problem:** Cannot start backend on port 8000

**Solution:**

1. **Find and kill the process:**
```bash
# Find process using port 8000
lsof -i :8000

# Kill it
kill -9 <PID>
```

2. **Or change the port:**
```bash
# Edit backend/.env
PORT=8001

# Edit frontend/.env
VITE_API_URL=http://localhost:8001
VITE_WS_URL=ws://localhost:8001
```

### Issue 5: Browser Cannot Access localhost

**Problem:** Cannot access http://localhost:5173 from Windows browser

**Solution:**

1. **Use WSL IP address instead:**
```bash
# Get WSL IP address
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# Example: 172.20.10.5
# Then access: http://172.20.10.5:5173
```

2. **Or configure port forwarding:**
```powershell
# In Windows PowerShell (as Administrator)
netsh interface portproxy add v4tov4 listenport=5173 listenaddress=0.0.0.0 connectport=5173 connectaddress=<WSL-IP>
```

3. **Update CORS settings:**
```bash
# In backend/.env, add your WSL IP
CORS_ORIGINS=http://localhost:5173,http://172.20.10.5:5173
```

### Issue 6: File Watching Issues

**Problem:** Hot reload doesn't work for frontend

**Solution:**

Add to `frontend/vite.config.js`:
```javascript
export default defineConfig({
  // ... existing config
  server: {
    watch: {
      usePolling: true,
    },
  },
})
```

---

## WSL Performance Tips

### 1. Keep Files in Linux Filesystem

**❌ Slow:**
```bash
cd /mnt/c/Users/YourName/Projects/heli_hack
```

**✅ Fast:**
```bash
cd ~/heli_hack
```

### 2. Allocate More Memory to WSL

Create or edit `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
```

Then restart WSL:
```powershell
wsl --shutdown
```

### 3. Enable systemd (for better service management)

In `/etc/wsl.conf`:
```ini
[boot]
systemd=true
```

---

## Testing on WSL

### Quick Test:

```bash
# Backend health check
curl http://localhost:8000/api/health

# Should return:
# {"status":"healthy","deepgram":"configured",...}
```

### Full Test:

```bash
# Start both services
./start.sh

# In another WSL terminal
curl http://localhost:8000/api/health

# In Windows browser
# Visit: http://localhost:5173
```

---

## Accessing from Windows

### Option 1: Use localhost (recommended)

WSL2 automatically forwards ports to Windows:
- Frontend: http://localhost:5173
- Backend: http://localhost:8000

### Option 2: Use WSL IP Address

```bash
# Get WSL IP
hostname -I | awk '{print $1}'

# Example: 172.20.10.5
# Access: http://172.20.10.5:5173
```

### Option 3: Use Windows Host File

Add to `C:\Windows\System32\drivers\etc\hosts`:
```
172.20.10.5  healthchat.local
```

Then access: http://healthchat.local:5173

---

## Debugging on WSL

### Check System Info:

```bash
# WSL version
wsl --version

# Linux distro
cat /etc/os-release

# Python version
python3 --version

# Node version
node --version

# Available memory
free -h

# Disk space
df -h
```

### Monitor Resources:

```bash
# CPU and memory usage
htop

# Or use top
top
```

### View Logs:

```bash
# Backend logs
cd backend
source venv/bin/activate
python -m app.main

# Frontend logs
cd frontend
npm run dev
```

---

## Clean Install on WSL

If everything fails, start fresh:

```bash
# 1. Remove existing installation
cd ~/heli_hack
rm -rf backend/venv frontend/node_modules

# 2. Install system dependencies
./fix-wsl.sh

# 3. Run setup
./setup.sh

# 4. Start services
./start.sh
```

---

## WSL-Specific Environment Variables

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Node environment
export NODE_OPTIONS="--max-old-space-size=4096"

# Python environment
export PYTHONUNBUFFERED=1

# Display for GUI apps (if needed)
export DISPLAY=:0

# Reload
source ~/.bashrc
```

---

## Getting Help

If you're still stuck after trying these solutions:

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Look at backend terminal output for Python errors
3. Check browser console (F12) for frontend errors
4. Verify all system dependencies are installed
5. Try the clean install process above

---

## Success Checklist

- [ ] System dependencies installed
- [ ] Python virtual environment created
- [ ] npm dependencies installed
- [ ] Backend starts without errors
- [ ] Frontend builds successfully
- [ ] Can access http://localhost:5173 from Windows browser
- [ ] 3D viewer loads
- [ ] No console errors

**All checked? You're ready to build!** 🚀

---

**WSL Version:** Tested on WSL2 with Ubuntu 22.04 and 24.04
