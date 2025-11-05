import { useState, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import BioDigitalViewer from '../BioDigitalViewer/BioDigitalViewer'
import VoiceInterface from '../VoiceInterface/VoiceInterface'
import { FaArrowLeft, FaUpload, FaMicrophone } from 'react-icons/fa'

function PatientMode() {
  const navigate = useNavigate()
  const [human, setHuman] = useState(null)
  const [uploadedFiles, setUploadedFiles] = useState([])
  const [isVoiceActive, setIsVoiceActive] = useState(false)

  const handleHumanReady = (humanInstance) => {
    setHuman(humanInstance)
    console.log('BioDigital Human ready in Patient Mode')
  }

  const handleFileUpload = (event) => {
    const files = Array.from(event.target.files)
    setUploadedFiles((prev) => [...prev, ...files])
    // TODO: Send files to backend for processing
  }

  return (
    <div className="min-h-screen p-4">
      {/* Header */}
      <div className="bg-white shadow-md rounded-lg p-4 mb-4 flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/')}
            className="text-blue-600 hover:text-blue-800 transition"
          >
            <FaArrowLeft className="text-2xl" />
          </button>
          <h1 className="text-2xl font-bold text-gray-800">Patient Mode</h1>
        </div>
        <div className="flex items-center space-x-4">
          <label className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg cursor-pointer flex items-center space-x-2 transition">
            <FaUpload />
            <span>Upload Reports</span>
            <input
              type="file"
              multiple
              accept=".pdf,.jpg,.jpeg,.png"
              onChange={handleFileUpload}
              className="hidden"
            />
          </label>
        </div>
      </div>

      {/* Main Content */}
      <div className="grid lg:grid-cols-2 gap-4 h-[calc(100vh-120px)]">
        {/* Left: 3D Viewer */}
        <div className="bg-white rounded-lg shadow-lg p-4">
          <h2 className="text-xl font-semibold mb-4 text-gray-800">
            3D Anatomy Explorer
          </h2>
          <BioDigitalViewer onHumanReady={handleHumanReady} mode="patient" />
        </div>

        {/* Right: Chat & Info Panel */}
        <div className="space-y-4">
          {/* Uploaded Files */}
          {uploadedFiles.length > 0 && (
            <div className="bg-white rounded-lg shadow-lg p-4">
              <h3 className="text-lg font-semibold mb-2 text-gray-800">
                Uploaded Reports
              </h3>
              <div className="space-y-2">
                {uploadedFiles.map((file, index) => (
                  <div
                    key={index}
                    className="bg-blue-50 p-2 rounded flex items-center justify-between"
                  >
                    <span className="text-sm text-gray-700">{file.name}</span>
                    <span className="text-xs text-gray-500">
                      {(file.size / 1024).toFixed(1)} KB
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Voice Interface */}
          <div className="bg-white rounded-lg shadow-lg p-4 flex-1">
            <VoiceInterface
              human={human}
              mode="patient"
              onVoiceStateChange={setIsVoiceActive}
            />
          </div>

          {/* Instructions */}
          <div className="bg-blue-50 rounded-lg p-4">
            <h3 className="text-lg font-semibold mb-2 text-gray-800">
              How to Use
            </h3>
            <ul className="text-sm text-gray-700 space-y-1">
              <li>1. Upload your medical reports or test results</li>
              <li>2. Click the microphone to start voice conversation</li>
              <li>3. Ask AI about your results and health concerns</li>
              <li>4. Watch as AI navigates the 3D anatomy model</li>
              <li>5. Get personalized health insights and recommendations</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export default PatientMode
