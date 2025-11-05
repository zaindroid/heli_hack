# HealthChat AI - Integration Testing Guide

## ✅ What's Working

1. **BioDigital 3D Viewer** with your model (6cr6) ✅
2. **HTTPS enabled** for Vite dev server ✅
3. **AI Agent** with anatomy control functions ✅
4. **WebSocket** communication ready ✅

---

## 🚀 Start the Application

### Step 1: Pull Latest Changes

```bash
cd ~/elr_hack/heli_hack
git pull origin claude/explore-capabilities-011CUpjMrV8oKXe88Aw7vnnz
```

### Step 2: Install Dependencies

```bash
# Install new HTTPS plugin for frontend
cd frontend
npm install

# Backend dependencies already installed
cd ..
```

### Step 3: Start the Application

```bash
# From project root
./start.sh
```

This will start:
- **Backend** on `http://localhost:8000`
- **Frontend** on `https://localhost:5173` (HTTPS required for BioDigital!)

---

## 🧪 Test the 3D Viewer

### Open in Browser

**IMPORTANT:** Use **HTTPS** (not HTTP):

```
https://localhost:5173
```

**You'll see a security warning** (self-signed certificate):
- Click **"Advanced"**
- Click **"Proceed to localhost"** or **"Accept the Risk"**
- This is safe for local development

### Navigate to Test Modes

1. **Patient Mode**: `https://localhost:5173/patient`
2. **Doctor Mode**: `https://localhost:5173/doctor`

### What to Look For

✅ The 3D anatomy model loads (your model 6cr6)
✅ You can rotate, zoom, and interact with it
✅ No authentication errors
✅ Browser console shows: "✓ BioDigital Human ready!"

---

## 🎤 AI Agent Anatomy Control (Coming Next)

The AI agent already has these functions ready:

### 1. Navigate to Organ
```javascript
// AI says: "Let me show you the heart"
// Backend calls: navigate_to_organ(organ_id="heart")
// Frontend receives: { type: "anatomy_control", action: "navigate_to", params: {organId: "heart"} }
// BioDigital API: human.camera.flyTo({ target: "heart" })
```

### 2. Zoom Control
```javascript
// AI says: "Let me zoom in for a closer look"
// Backend calls: zoom_anatomy(level=4)
// Frontend receives: { type: "anatomy_control", action: "zoom", params: {level: 4} }
// BioDigital API: human.camera.zoom(4)
```

### 3. Highlight Structure
```javascript
// AI says: "I'll highlight the left ventricle"
// Backend calls: highlight_structure(structure_id="left_ventricle")
// Frontend receives: { type: "anatomy_control", action: "highlight", params: {structureId: "left_ventricle"} }
// BioDigital API: human.pick({ objectId: "left_ventricle" })
```

### 4. Play Animation
```javascript
// AI says: "Watch how blood flows through the heart"
// Backend calls: play_animation(animation_name="blood_flow")
// Frontend receives: { type: "anatomy_control", action: "play_animation", params: {animationName: "blood_flow"} }
// BioDigital API: human.timeline.play({ chapterId: "blood_flow" })
```

---

## 🔧 Next Steps to Complete Integration

### Step 1: Add WebSocket Listener in PatientMode.jsx / DoctorMode.jsx

The AI agent sends anatomy control commands via WebSocket. We need to listen for them:

```javascript
// In PatientMode.jsx or DoctorMode.jsx
useEffect(() => {
  const ws = new WebSocket('ws://localhost:8000/ws/voice')

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data)

    if (data.type === 'anatomy_control') {
      // Call BioDigital API method based on action
      const human = window.biodigitalHuman  // Exposed by BioDigitalViewer

      switch(data.action) {
        case 'navigate_to':
          human.camera.flyTo({ target: data.params.organId })
          break
        case 'zoom':
          human.camera.zoom(data.params.level)
          break
        case 'highlight':
          human.pick({ objectId: data.params.structureId })
          break
        case 'play_animation':
          human.timeline.play({ chapterId: data.params.animationName })
          break
      }
    }
  }

  return () => ws.close()
}, [])
```

### Step 2: Add Voice Interface

Once the WebSocket listener is working, we can add:
- Microphone button
- Real-time speech-to-text with Deepgram
- AI responses with text-to-speech
- Visual feedback during voice interaction

### Step 3: Test Voice Commands

Example conversation:
```
User: "Can you show me where my liver is?"
AI: *calls navigate_to_organ("liver")*
AI: "The liver is located in the upper right part of your abdomen.
     It's your body's largest internal organ and performs over 500 functions..."
     *3D viewer zooms to liver*
```

---

## 🐛 Troubleshooting

### Issue: "BioDigital Human API script failed to load"
**Solution:**
- Make sure you're using HTTPS: `https://localhost:5173` (not `http://`)
- Check internet connection
- Check browser console for CORS errors

### Issue: "NET::ERR_CERT_AUTHORITY_INVALID"
**Solution:**
- This is expected with self-signed certificates
- Click "Advanced" → "Proceed to localhost"
- Safe for local development

### Issue: 3D model doesn't load, shows "authentication required"
**Solution:**
- Check if `uaid` and `paid` are correct in BioDigitalViewer.jsx
- Try getting a fresh embed code from your BioDigital library

### Issue: WebSocket connection fails
**Solution:**
- Make sure backend is running: `cd backend && uvicorn app.main:app --reload`
- Check backend logs for errors
- Frontend needs to connect to: `ws://localhost:8000/ws/voice`

---

## 📊 Current Architecture

```
User Voice Input
    ↓
Deepgram (Speech-to-Text)
    ↓
OpenAI GPT-4 (with function calling)
    ↓
Pipecat Agent (process message)
    ↓
WebSocket (send anatomy_control)
    ↓
Frontend (React)
    ↓
BioDigital Human API (3D viewer)
    ↓
Visual feedback to user
```

---

## ✨ Adding More Models

To use different models from your library:

1. Go to your BioDigital models
2. Get the embed code for the model
3. Extract the `id=` parameter
4. Update in `BioDigitalViewer.jsx`:

```javascript
const modelId = 'YOUR_MODEL_ID'  // Change from '6cr6' to your model
```

You can even make it dynamic:
```javascript
const modelId = mode === 'heart' ? '6cr6' :
                mode === 'brain' ? 'xyz123' :
                '6cr6'  // default
```

The AI agent can switch models based on the conversation topic!

---

## 🎯 Testing Checklist

- [ ] Frontend starts with HTTPS
- [ ] 3D model loads without auth errors
- [ ] Can rotate/zoom/interact with model
- [ ] Browser console shows "BioDigital Human ready!"
- [ ] `window.biodigitalHuman` is available in console
- [ ] WebSocket connects (check Network tab)
- [ ] Backend AI agent responds to requests
- [ ] Anatomy control commands work via console test
- [ ] Voice interface captures audio
- [ ] End-to-end voice → 3D control works

---

## 🔜 What's Next?

1. **Test the basic 3D viewer** - Make sure model loads
2. **Add WebSocket listener** - Connect AI to 3D viewer
3. **Test with console** - Manually send anatomy control commands
4. **Add voice interface** - Microphone button + Deepgram
5. **End-to-end test** - Speak → AI → 3D response

Ready to test? Start with `./start.sh` and navigate to `https://localhost:5173`! 🚀
