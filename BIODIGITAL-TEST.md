# BioDigital API Test Tool 🧪

Before running HealthChat AI, use this tool to verify your BioDigital API is working correctly.

## 🚀 Quick Start

### **Option 1: Automatic (Recommended)**

```bash
./test-biodigital.sh
```

This will open the test page in your default browser.

### **Option 2: Manual**

```bash
# Open the HTML file in your browser
# On Linux/WSL:
xdg-open test-biodigital.html

# On macOS:
open test-biodigital.html

# On Windows (from WSL):
wslview test-biodigital.html
```

### **Option 3: Direct File Access**

1. Navigate to your project directory in file explorer
2. Double-click `test-biodigital.html`
3. It will open in your default browser

---

## 📋 What It Tests

The test suite runs **5 comprehensive tests**:

### **Test 1: Internet Connection** 🌐
- Checks if you can reach the internet
- Tests connectivity to google.com
- **If this fails:** Check your network connection

### **Test 2: BioDigital Domain Access** 🔗
- Checks if you can reach human.biodigital.com
- Tests if the domain is blocked by firewall/VPN
- **If this fails:**
  - Check firewall settings
  - Try disabling VPN
  - Check DNS settings

### **Test 3: HumanAPI Script Loading** 📜
- Loads the BioDigital JavaScript library
- Tests if the script can be downloaded
- **If this fails:**
  - Check internet speed
  - Try opening the URL directly: https://human.biodigital.com/builds/api/2/human-api.min.js
  - Check browser console for CORS errors

### **Test 4: API Key Validation** 🔑
- Validates your BioDigital API key
- Tests if the key is authorized
- **If this fails:**
  - API key is incorrect or expired
  - Get a new key from https://human.biodigital.com/developers
  - Make sure you copied the entire key

### **Test 5: 3D Model Loading** 🧬
- Loads a default 3D human anatomy model
- Tests if the viewer works properly
- **If this passes:** You should see a 3D model you can interact with!

---

## ✅ Expected Results

### **All Tests Pass:**

```
Test Results
🎉
All tests passed!
Your BioDigital API is configured correctly and working perfectly.
You can now use HealthChat AI with 3D anatomy visualization!
```

You'll also see a fully loaded 3D anatomy model that you can:
- Rotate with mouse drag
- Zoom with scroll wheel
- Interact with controls

### **Some Tests Fail:**

The test page will show:
- ❌ Which tests failed
- 📝 Exact error messages
- 💡 Specific solutions for each issue

---

## 🔧 Common Issues & Solutions

### Issue 1: "BioDigital Human API script failed to load"

**Cause:** Can't download the JavaScript library

**Solutions:**
```bash
# Test if you can access the script URL
curl -I https://human.biodigital.com/builds/api/2/human-api.min.js

# If this fails, check:
# 1. Internet connection
# 2. Firewall/antivirus blocking
# 3. VPN issues
```

### Issue 2: "API KEY IS INVALID!"

**Cause:** Wrong or expired API key

**Solutions:**
1. Go to https://human.biodigital.com/developers
2. Log in to your account
3. Generate a new API key
4. Copy the ENTIRE key (usually 40 characters)
5. Paste it in the test page input field
6. Run tests again

### Issue 3: Test 1 or 2 Fails (Internet/Domain Access)

**Cause:** Network connectivity issues

**Solutions:**

**On WSL:**
```bash
# Check if WSL can reach internet
ping google.com

# Check DNS resolution
nslookup human.biodigital.com

# If DNS fails, update /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'

# Restart WSL
exit
# In Windows PowerShell:
wsl --shutdown
wsl
```

**On Linux:**
```bash
# Check connectivity
ping -c 3 human.biodigital.com

# Check if firewall is blocking
sudo iptables -L | grep DROP

# Temporarily disable firewall (for testing only!)
sudo ufw disable
# Run test
sudo ufw enable
```

### Issue 4: "Script loading timed out"

**Cause:** Very slow internet or the script is blocked

**Solutions:**
1. Check internet speed: https://fast.com
2. Try accessing BioDigital website directly: https://human.biodigital.com
3. Check browser console (F12) for specific errors
4. Try a different browser
5. Try a different network (mobile hotspot, etc.)

---

## 📊 Reading Test Results

### Success Indicators:
- ✅ Green checkmark = Test passed
- 🟢 Green border = Section successful
- Green background text = Success message

### Error Indicators:
- ❌ Red X = Test failed
- 🔴 Red border = Section failed
- Red background text = Error details

### In Progress:
- 🔄 Spinner = Test running
- 🟡 Yellow border = Currently testing

---

## 🎯 Using Test Results

### **If All Tests Pass:**

```bash
# You're ready to run HealthChat AI!
cd ~/elr_hack/heli_hack
./start.sh

# Visit: http://localhost:5173
# Navigate to Patient or Doctor mode
# The 3D viewer should work perfectly!
```

### **If Tests Fail:**

1. **Read the error message carefully**
   - Each test shows specific error details
   - Follow the suggested solutions

2. **Fix the issue**
   - Update API key if needed
   - Check network/firewall settings
   - Install missing dependencies

3. **Run the test again**
   - Click "Run Tests" button
   - Verify the issue is fixed

4. **Only proceed to HealthChat AI when all tests pass**

---

## 🔍 Advanced Debugging

### Check Browser Console:

1. Open the test page
2. Press **F12** to open Developer Tools
3. Go to **Console** tab
4. Run tests
5. Look for detailed error messages

### Network Tab Analysis:

1. Open Developer Tools (F12)
2. Go to **Network** tab
3. Run tests
4. Look for failed requests (red text)
5. Click on failed requests to see details

### Check Specific Endpoints:

```bash
# Test if script URL is accessible
curl -I https://human.biodigital.com/builds/api/2/human-api.min.js

# Test if domain is reachable
curl -I https://human.biodigital.com

# Test with verbose output
curl -v https://human.biodigital.com/builds/api/2/human-api.min.js
```

---

## 💡 Tips

1. **Run this test FIRST** before trying to use HealthChat AI
2. **Save the test page URL** for future testing
3. **Test on different networks** if you have connectivity issues
4. **Try different browsers** if one doesn't work
5. **Check the test page regularly** if you update your API key

---

## 📱 WSL-Specific Issues

### Opening in Windows Browser from WSL:

```bash
# Install wslu if not already installed
sudo apt install wslu

# Open test page
wslview test-biodigital.html

# Or get the Windows path and open manually
wslpath -w "$(pwd)/test-biodigital.html"
# Copy the output and paste in browser
```

### Network Issues on WSL:

```bash
# Check if WSL can reach internet
ping -c 3 8.8.8.8

# If not, restart WSL networking
# In Windows PowerShell (as Administrator):
wsl --shutdown
# Then restart WSL
```

---

## 🆘 Still Not Working?

If the test still fails after trying all solutions:

1. **Check BioDigital Status:**
   - Visit https://human.biodigital.com
   - Make sure the service is online

2. **Verify API Key:**
   - Log in to BioDigital developers portal
   - Check if your key is active
   - Generate a new key if needed

3. **Test on Different Device:**
   - Try the test page on your phone
   - Try on a different computer
   - This helps identify if it's a local issue

4. **Contact BioDigital Support:**
   - If your key is valid but doesn't work
   - If their service seems down
   - Visit: https://support.biodigital.com

5. **Check HealthChat AI Issues:**
   - The test page is working but HealthChat AI isn't?
   - Open an issue on GitHub
   - Include test results in your report

---

## 📄 Test Results Interpretation

### Scenario 1: All Tests Pass ✅
**Status:** Everything is working perfectly!
**Action:** Proceed to use HealthChat AI

### Scenario 2: Tests 1-3 Pass, Test 4 Fails ❌
**Status:** Network is fine, but API key is invalid
**Action:** Get a new API key from BioDigital

### Scenario 3: Tests 1-2 Pass, Test 3 Fails ❌
**Status:** Internet works, but can't load BioDigital script
**Action:** Check firewall, VPN, or try different browser

### Scenario 4: Test 1 Fails ❌
**Status:** No internet connection
**Action:** Fix network connection first

### Scenario 5: Test 1 Passes, Test 2 Fails ❌
**Status:** Internet works but can't reach BioDigital domain
**Action:** Check DNS, firewall, or VPN settings

---

## 🎨 Visual Features

The test page includes:
- 🎨 Beautiful gradient design
- 📊 Real-time progress indicators
- 🔄 Animated spinners during tests
- ✅ Green success states
- ❌ Red error states with solutions
- 🎯 Interactive 3D viewer on success
- 📱 Responsive design (works on mobile too!)

---

## 🔗 Useful Links

- BioDigital Developers: https://human.biodigital.com/developers
- BioDigital API Docs: https://developer.biodigital.com
- Get API Key: https://human.biodigital.com/developers
- BioDigital Support: https://support.biodigital.com
- HealthChat AI Repo: https://github.com/zaindroid/heli_hack

---

**Happy Testing!** 🧪🎉

If all tests pass, you're ready to experience HealthChat AI with immersive 3D anatomy visualization!
