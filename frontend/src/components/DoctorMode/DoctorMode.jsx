import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import BioDigitalViewer from '../BioDigitalViewer/BioDigitalViewer'
import VoiceInterface from '../VoiceInterface/VoiceInterface'
import { FaArrowLeft, FaUpload, FaUserInjured } from 'react-icons/fa'

function DoctorMode() {
  const navigate = useNavigate()
  const [human, setHuman] = useState(null)
  const [patientFiles, setPatientFiles] = useState([])
  const [patientInfo, setPatientInfo] = useState({
    name: '',
    age: '',
    gender: '',
    history: '',
  })

  const handleHumanReady = (humanInstance) => {
    setHuman(humanInstance)
    console.log('BioDigital Human ready in Doctor Mode')
  }

  const handleFileUpload = (event) => {
    const files = Array.from(event.target.files)
    setPatientFiles((prev) => [...prev, ...files])
    // TODO: Send files to backend for processing
  }

  return (
    <div className="min-h-screen p-4">
      {/* Header */}
      <div className="bg-white shadow-md rounded-lg p-4 mb-4 flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/')}
            className="text-green-600 hover:text-green-800 transition"
          >
            <FaArrowLeft className="text-2xl" />
          </button>
          <h1 className="text-2xl font-bold text-gray-800">Doctor Mode</h1>
          <div className="bg-green-100 px-3 py-1 rounded-full">
            <span className="text-green-700 text-sm font-semibold">
              Professional
            </span>
          </div>
        </div>
        <div className="flex items-center space-x-4">
          <label className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg cursor-pointer flex items-center space-x-2 transition">
            <FaUpload />
            <span>Upload Patient Reports</span>
            <input
              type="file"
              multiple
              accept=".pdf,.jpg,.jpeg,.png,.dcm"
              onChange={handleFileUpload}
              className="hidden"
            />
          </label>
        </div>
      </div>

      <div className="grid lg:grid-cols-3 gap-4 h-[calc(100vh-120px)]">
        {/* Left: Patient Info */}
        <div className="space-y-4">
          <div className="bg-white rounded-lg shadow-lg p-4">
            <div className="flex items-center space-x-2 mb-4">
              <FaUserInjured className="text-green-600 text-xl" />
              <h3 className="text-lg font-semibold text-gray-800">
                Patient Information
              </h3>
            </div>
            <div className="space-y-3">
              <input
                type="text"
                placeholder="Patient Name"
                value={patientInfo.name}
                onChange={(e) =>
                  setPatientInfo({ ...patientInfo, name: e.target.value })
                }
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-green-500"
              />
              <div className="grid grid-cols-2 gap-2">
                <input
                  type="number"
                  placeholder="Age"
                  value={patientInfo.age}
                  onChange={(e) =>
                    setPatientInfo({ ...patientInfo, age: e.target.value })
                  }
                  className="px-3 py-2 border rounded-lg focus:ring-2 focus:ring-green-500"
                />
                <select
                  value={patientInfo.gender}
                  onChange={(e) =>
                    setPatientInfo({ ...patientInfo, gender: e.target.value })
                  }
                  className="px-3 py-2 border rounded-lg focus:ring-2 focus:ring-green-500"
                >
                  <option value="">Gender</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <textarea
                placeholder="Medical History"
                value={patientInfo.history}
                onChange={(e) =>
                  setPatientInfo({ ...patientInfo, history: e.target.value })
                }
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-green-500 h-24"
              />
            </div>
          </div>

          {/* Uploaded Files */}
          {patientFiles.length > 0 && (
            <div className="bg-white rounded-lg shadow-lg p-4">
              <h3 className="text-lg font-semibold mb-2 text-gray-800">
                Patient Reports
              </h3>
              <div className="space-y-2 max-h-64 overflow-y-auto">
                {patientFiles.map((file, index) => (
                  <div
                    key={index}
                    className="bg-green-50 p-2 rounded flex items-center justify-between"
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

          {/* Quick Actions */}
          <div className="bg-white rounded-lg shadow-lg p-4">
            <h3 className="text-lg font-semibold mb-2 text-gray-800">
              Quick Actions
            </h3>
            <div className="space-y-2">
              <button className="w-full bg-green-500 hover:bg-green-600 text-white py-2 rounded-lg transition">
                Analyze Reports
              </button>
              <button className="w-full bg-blue-500 hover:bg-blue-600 text-white py-2 rounded-lg transition">
                View History
              </button>
              <button className="w-full bg-purple-500 hover:bg-purple-600 text-white py-2 rounded-lg transition">
                Generate Summary
              </button>
            </div>
          </div>
        </div>

        {/* Center: 3D Viewer */}
        <div className="bg-white rounded-lg shadow-lg p-4">
          <h2 className="text-xl font-semibold mb-4 text-gray-800">
            Advanced 3D Anatomy & Surgical Planning
          </h2>
          <BioDigitalViewer onHumanReady={handleHumanReady} mode="doctor" />
        </div>

        {/* Right: AI Assistant */}
        <div className="bg-white rounded-lg shadow-lg p-4">
          <VoiceInterface human={human} mode="doctor" />
        </div>
      </div>
    </div>
  )
}

export default DoctorMode
