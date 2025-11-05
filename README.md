# HealthChat AI 🏥

**Interactive Medical Assistant with AI-Powered 3D Anatomy Visualization**

HealthChat AI is an innovative healthcare application that makes medical data exploration fun and accessible through conversational AI and immersive 3D anatomy visualization powered by BioDigital Human.

## ⚡ Quick Start

### One-Command Setup

**Linux/Mac:**
```bash
git clone <your-repo-url>
cd heli_hack
./setup.sh
./start.sh
```

**Windows:**
```cmd
git clone <your-repo-url>
cd heli_hack
setup.bat
start.bat
```

**Windows (WSL):**
```bash
git clone <your-repo-url>
cd heli_hack
./fix-wsl.sh    # Install system dependencies first
./setup.sh
./start.sh
```

> **WSL Users:** See [WSL-SETUP.md](WSL-SETUP.md) for detailed WSL-specific instructions and troubleshooting.

Then visit: **http://localhost:5173** 🚀

### What the scripts do:
- ✅ Check prerequisites (Python 3.11+, Node.js 18+)
- ✅ Create Python virtual environment
- ✅ Install all dependencies (backend + frontend)
- ✅ Verify environment configuration
- ✅ Start both services automatically

---

## 🌟 Features

### Patient Mode
- 📄 Upload medical reports and test results (PDF, images)
- 🎙️ Voice conversation with AI to understand health data
- 🧬 Interactive 3D anatomy visualization with AI navigation
- 💊 Home remedies and precautions
- 📹 Live video symptom analysis
- ⚕️ Risk assessment and doctor consultation recommendations

### Doctor Mode
- 👨‍⚕️ Patient history and multi-report analysis
- 🔬 Detailed clinical insights and diagnostics
- 🏥 Surgery planning with advanced 3D models
- 🎯 AI-guided anatomy navigation for education
- 📊 Treatment recommendations based on evidence

## 🏗️ Architecture

```
heli_hack/
├── frontend/              # React + Vite frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── PatientMode/
│   │   │   ├── DoctorMode/
│   │   │   ├── BioDigitalViewer/
│   │   │   └── VoiceInterface/
│   │   ├── App.jsx
│   │   └── main.jsx
│   └── package.json
├── backend/               # FastAPI + Pipecat backend
│   ├── app/
│   │   ├── main.py
│   │   ├── pipecat_agent.py
│   │   └── report_parser.py
│   └── requirements.txt
└── docker-compose.yml
```

## 🚀 Tech Stack

**Frontend:**
- React.js + Vite
- Tailwind CSS
- BioDigital Human Viewer API
- WebRTC for video
- WebSocket for real-time communication

**Backend:**
- FastAPI (Python)
- Pipecat AI for voice agent
- OpenAI GPT-4 for intelligence
- Deepgram for speech recognition
- PyPDF2 & Tesseract for document processing

**APIs:**
- BioDigital Human API (3D Anatomy)
- OpenAI API (LLM)
- Deepgram API (Speech-to-Text)

## 📋 Prerequisites

- Node.js 18+ and npm
- Python 3.11+
- Docker and Docker Compose (optional)

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd heli_hack
```

### 2. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Environment variables are already configured in .env file
# Verify the .env file has all API keys

# Run backend
python -m app.main
```

Backend will run on `http://localhost:8000`

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Environment variables are already in .env file
# Verify frontend/.env has correct API keys

# Run development server
npm run dev
```

Frontend will run on `http://localhost:5173`

### 4. Docker Deployment (Recommended for Production)

```bash
# Build and run all services
docker-compose up --build

# Run in background
docker-compose up -d

# Stop services
docker-compose down
```

Access the application:
- Frontend: `http://localhost`
- Backend API: `http://localhost:8000`
- API Docs: `http://localhost:8000/docs`

## 🎮 Usage

### Patient Mode

1. Navigate to the homepage and select "Patient Mode"
2. Upload your medical reports (PDF or images)
3. Click the microphone icon to start voice conversation
4. Ask AI about your test results and health concerns
5. Watch as AI autonomously navigates the 3D anatomy model
6. Get personalized health insights and recommendations

**Example Questions:**
- "What does my high cholesterol mean?"
- "Explain my blood test results"
- "Should I see a doctor for this?"

### Doctor Mode

1. Select "Doctor Mode" from homepage
2. Enter patient information
3. Upload patient reports and medical history
4. Use voice interface to discuss cases with AI
5. AI provides detailed clinical insights
6. Explore 3D anatomy for surgical planning
7. Get evidence-based treatment recommendations

**Example Queries:**
- "Analyze this patient's cardiac profile"
- "Show me the surgical approach for appendectomy"
- "What's the differential diagnosis for these symptoms?"

## 🔑 API Keys Configuration

The application requires the following API keys (already configured):

- **Deepgram API**: For speech-to-text conversion
- **BioDigital Human API**: For 3D anatomy visualization
- **OpenAI API**: For AI intelligence and responses

Keys are stored in:
- `backend/.env` - Backend configuration
- `frontend/.env` - Frontend configuration

## 🧪 Testing Locally

### Test Backend Health

```bash
curl http://localhost:8000/api/health
```

### Test File Upload

```bash
curl -X POST http://localhost:8000/api/upload \
  -F "file=@/path/to/medical-report.pdf"
```

### Test WebSocket Connection

Open browser console at `http://localhost:5173` and check WebSocket connections.

## 🎯 Demo Use Cases

### Use Case 1: Blood Test Analysis
1. Patient uploads CBC (Complete Blood Count) report
2. AI explains elevated WBC count
3. Navigates to immune system in 3D model
4. Shows animation of white blood cell function
5. Recommends follow-up with doctor

### Use Case 2: Pre-Surgery Consultation
1. Doctor enters patient information
2. Uploads CT scan and medical history
3. AI analyzes surgical requirements
4. Shows 3D anatomy of surgical site
5. Provides step-by-step surgical approach

### Use Case 3: Symptom Video Analysis
1. Patient describes symptoms via voice
2. Shows affected area to camera
3. AI analyzes visual symptoms
4. Provides risk assessment
5. Recommends home care or doctor visit

## 🚢 AWS Deployment

The application is designed for easy AWS deployment:

### Services Used:
- **AWS Lambda**: Backend API
- **AWS S3**: File storage
- **AWS API Gateway**: REST API and WebSocket
- **AWS CloudFront**: Frontend hosting
- **AWS DynamoDB**: Data storage (optional)

### Deployment Steps:

```bash
# Install AWS CLI
pip install awscli

# Configure AWS credentials
aws configure

# Deploy using SAM or Serverless Framework
# (Detailed deployment scripts can be added)
```

## 📊 Key Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Frontend | React + Vite | Fast, modern UI |
| 3D Viewer | BioDigital Human API | Anatomy visualization |
| Backend | FastAPI | High-performance API |
| AI Agent | Pipecat | Voice conversation |
| LLM | OpenAI GPT-4 | Intelligence & reasoning |
| Speech | Deepgram | Voice recognition |
| OCR | Tesseract | Document parsing |

## 🎨 Features Roadmap

- [x] Patient and Doctor modes
- [x] Voice AI interface
- [x] 3D anatomy navigation
- [x] Report upload and parsing
- [ ] Live video symptom analysis (MediaPipe)
- [ ] Multi-language support
- [ ] Mobile app (React Native)
- [ ] Integration with EHR systems
- [ ] Prescription generation
- [ ] Appointment scheduling

## 🤝 Contributing

This is a hackathon project. Contributions are welcome!

## 📄 License

MIT License - feel free to use for educational and hackathon purposes.

## 🏆 Hackathon Information

**Challenge**: Health Chat - Make Data Exploration Fun & Useful
**Goal**: Create AI-powered interfaces for healthcare data exploration
**Technologies**: Amazon Bedrock (compatible), GenAI, BioDigital Human

## 📞 Support

For issues or questions:
1. Check the API health endpoint: `/api/health`
2. Review browser console for frontend errors
3. Check backend logs for API issues

## 🎓 Demo Script

### 2-Minute Demo Flow:

1. **Introduction (15s)**
   - Show homepage with two modes
   - Explain the concept

2. **Patient Mode Demo (45s)**
   - Upload blood test report
   - Ask "What does my high cholesterol mean?"
   - Watch AI navigate to heart in 3D
   - Show animation of arterial plaque

3. **Doctor Mode Demo (45s)**
   - Enter patient info
   - Upload CT scan
   - Ask for surgical planning
   - AI shows detailed anatomy
   - Provides clinical recommendations

4. **Closing (15s)**
   - Highlight AI autonomous navigation
   - Mention AWS-ready architecture
   - Thank judges

---

**Built with ❤️ for Healthcare Innovation**
