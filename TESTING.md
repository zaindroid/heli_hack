# Testing Guide 🧪

Quick guide to test HealthChat AI after setup.

## Before Testing

Make sure services are running:
```bash
# Check backend
curl http://localhost:8000/api/health

# Should return:
# {"status": "healthy", "deepgram": "configured", ...}
```

Visit frontend: http://localhost:5173

---

## Test 1: Homepage ✅

**Expected:**
- [ ] Homepage loads without errors
- [ ] Two mode cards visible (Patient & Doctor)
- [ ] Both cards are clickable
- [ ] Hover effects work

**How to Test:**
1. Open http://localhost:5173
2. Hover over Patient Mode card
3. Hover over Doctor Mode card
4. Click Patient Mode (should navigate)
5. Go back and click Doctor Mode

---

## Test 2: Patient Mode Interface ✅

**Expected:**
- [ ] Patient mode page loads
- [ ] 3D BioDigital viewer initializes
- [ ] Voice interface panel visible
- [ ] Upload button works
- [ ] Back button returns to homepage

**How to Test:**
1. Navigate to Patient Mode
2. Wait for 3D model to load (may take 10-15 seconds)
3. Check for "3D Anatomy Explorer" panel
4. Check for voice interface on the right
5. Click "Upload Reports" button
6. Try uploading a PDF or image file

---

## Test 3: BioDigital 3D Viewer ✅

**Expected:**
- [ ] 3D human model loads
- [ ] Can rotate the model with mouse
- [ ] Can zoom in/out
- [ ] No console errors about API key

**How to Test:**
1. Wait for model to fully load
2. Click and drag to rotate
3. Use scroll wheel to zoom
4. Right-click for additional controls

**Troubleshooting:**
- If model doesn't load, check browser console (F12)
- Verify `VITE_BIODIGITAL_API_KEY` in `frontend/.env`
- Check for CORS errors

---

## Test 4: Voice Interface Connection ✅

**Expected:**
- [ ] Voice interface shows "Disconnected" initially
- [ ] Clicking microphone attempts connection
- [ ] Connection status updates
- [ ] WebSocket connects to backend

**How to Test:**
1. Open browser DevTools (F12) → Network tab
2. Filter for "WS" (WebSocket)
3. Click the microphone button
4. Check if WebSocket connection is established
5. Status should change to "Connected"

**Check Backend Logs:**
```bash
# You should see in backend terminal:
# INFO: New voice connection: ... (mode: patient)
```

**Troubleshooting:**
- If connection fails, check backend is running
- Check `VITE_WS_URL=ws://localhost:8000` in `frontend/.env`
- Look for errors in browser console

---

## Test 5: AI Text Chat (Without Voice) ✅

**Expected:**
- [ ] Can send text messages to AI
- [ ] AI responds with text
- [ ] Messages appear in chat interface
- [ ] No errors in console

**How to Test:**

1. **Modify frontend code temporarily** for testing:

Edit `frontend/src/components/VoiceInterface/VoiceInterface.jsx`:

Add this button inside the `<div className="flex items-center justify-center space-x-4">` section:

```jsx
<input
  type="text"
  placeholder="Type message (for testing)"
  onKeyPress={(e) => {
    if (e.key === 'Enter' && wsRef.current) {
      wsRef.current.send(JSON.stringify({
        type: 'text',
        text: e.target.value
      }));
      e.target.value = '';
    }
  }}
  className="border px-3 py-2 rounded-lg"
/>
```

2. Connect voice interface
3. Type a message: "What is the heart?"
4. Press Enter
5. Check for AI response

**Expected AI Behavior:**
- Should respond with information about the heart
- May call anatomy navigation functions
- Response appears in chat

---

## Test 6: File Upload ✅

**Expected:**
- [ ] Can select PDF or image files
- [ ] Files appear in "Uploaded Reports" section
- [ ] File names and sizes display correctly
- [ ] Backend receives files

**How to Test:**
1. Click "Upload Reports" button
2. Select a PDF or JPG file (any file for testing)
3. Check if file appears in the list
4. Check backend terminal for upload logs

**Create Test File:**
```bash
# Create a dummy PDF for testing
echo "Test Medical Report" > test_report.txt
# Then upload test_report.txt renamed as .pdf
```

---

## Test 7: Doctor Mode ✅

**Expected:**
- [ ] Doctor mode interface loads
- [ ] Patient information form visible
- [ ] 3D viewer works
- [ ] Voice interface available
- [ ] Green theme applied

**How to Test:**
1. Go to homepage
2. Click "Doctor Mode"
3. Enter patient information:
   - Name: "Test Patient"
   - Age: "45"
   - Gender: "Male"
4. Check if data persists while on page
5. Upload a file
6. Test voice interface

---

## Test 8: API Endpoints ✅

**Test Backend Directly:**

```bash
# Health check
curl http://localhost:8000/api/health

# Expected: {"status": "healthy", ...}

# Root endpoint
curl http://localhost:8000/

# Expected: {"status": "healthy", "service": "HealthChat AI"}

# API documentation
# Visit: http://localhost:8000/docs
# Should show FastAPI Swagger UI
```

---

## Test 9: OpenAI Integration ✅

**Expected:**
- [ ] AI generates intelligent responses
- [ ] Function calling works (anatomy controls)
- [ ] No API errors

**How to Test:**
1. Connect voice interface in Patient Mode
2. Send test message: "Explain what the heart does"
3. Check AI response quality
4. Look for function calls in browser DevTools:
   - Should see `anatomy_control` messages
   - With actions like `navigate_to`, `zoom`, etc.

**Check Backend Logs:**
```bash
# Should see:
# INFO: AI calling function: navigate_to_organ with args: {'organ_id': 'heart'}
```

---

## Test 10: Error Handling ✅

**Expected:**
- [ ] Graceful error messages
- [ ] No crashes
- [ ] User-friendly error display

**How to Test:**

1. **Test with invalid API key:**
   - Temporarily change OpenAI key in `backend/.env`
   - Restart backend
   - Try to send a message
   - Should show error message (not crash)

2. **Test backend disconnection:**
   - Stop backend while frontend is running
   - Try to connect voice interface
   - Should show "Connection Error"

3. **Test with missing file:**
   - Try to upload very large file (> 10MB)
   - Should handle gracefully

---

## Performance Tests 🚀

### Test 11: Load Time

**Measure:**
1. Open browser DevTools → Network tab
2. Reload page
3. Check "Load" time
4. **Target:** < 3 seconds for initial load

### Test 12: 3D Model Load Time

**Measure:**
1. Time from page load to model visible
2. **Target:** < 15 seconds

### Test 13: AI Response Time

**Measure:**
1. Send message: "What is cholesterol?"
2. Time until first response
3. **Target:** < 5 seconds

---

## Automated Test Checklist

Run through this checklist systematically:

### Setup Phase
- [ ] `./setup.sh` runs without errors
- [ ] Backend dependencies install
- [ ] Frontend dependencies install
- [ ] `.env` files exist

### Backend Tests
- [ ] Backend starts on port 8000
- [ ] `/api/health` returns 200
- [ ] `/docs` loads Swagger UI
- [ ] WebSocket endpoint accessible

### Frontend Tests
- [ ] Frontend starts on port 5173
- [ ] Homepage loads
- [ ] Patient mode loads
- [ ] Doctor mode loads
- [ ] 3D viewer initializes
- [ ] No console errors (except warnings OK)

### Integration Tests
- [ ] Voice interface connects
- [ ] WebSocket communication works
- [ ] File upload works
- [ ] AI responses work
- [ ] 3D navigation works

### UI/UX Tests
- [ ] Buttons are clickable
- [ ] Forms accept input
- [ ] Navigation works
- [ ] Responsive layout (resize browser)
- [ ] No visual glitches

---

## Common Test Scenarios

### Scenario 1: New Patient Upload

```
1. Patient Mode → Upload blood test PDF
2. Click microphone to connect
3. Say: "What does my cholesterol level mean?"
4. AI should:
   - Respond with explanation
   - Navigate to heart/arteries in 3D
   - Provide recommendations
```

### Scenario 2: Doctor Consultation

```
1. Doctor Mode → Enter patient info
2. Upload multiple reports
3. Click microphone
4. Say: "Analyze this patient's cardiac risk"
5. AI should:
   - Provide clinical analysis
   - Show relevant anatomy
   - Suggest diagnostics
```

### Scenario 3: Symptom Check

```
1. Patient Mode → Connect voice
2. Say: "I have chest pain and shortness of breath"
3. AI should:
   - Ask clarifying questions
   - Show heart/lungs in 3D
   - Recommend seeing a doctor urgently
```

---

## Browser Compatibility

Test in multiple browsers:

- [ ] **Chrome/Edge** (Chromium) - Primary target
- [ ] **Firefox** - Should work
- [ ] **Safari** - May have WebSocket issues
- [ ] **Mobile Chrome** - Basic functionality

---

## Debug Mode

**Enable verbose logging:**

1. **Backend:**
```python
# In backend/app/main.py, change logging level:
logging.basicConfig(level=logging.DEBUG)
```

2. **Frontend:**
```javascript
// Add to VoiceInterface.jsx:
console.log('WebSocket message:', data);
```

---

## Quick Smoke Test (2 Minutes)

If you're in a hurry, run this:

1. ✅ Visit http://localhost:5173
2. ✅ Click Patient Mode
3. ✅ Wait for 3D model to load
4. ✅ Click microphone (should connect)
5. ✅ Upload any file
6. ✅ Check no red errors in console

**All green? You're good to go!** 🎉

---

## Reporting Issues

If tests fail:

1. Note which test failed
2. Check browser console (F12)
3. Check backend terminal logs
4. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
5. Include error messages in your report

---

**Ready to build features?** All tests passing means the foundation is solid! 🚀
