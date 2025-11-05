import { useNavigate } from 'react-router-dom'
import { FaUserMd, FaUser } from 'react-icons/fa'

function HomePage() {
  const navigate = useNavigate()

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4">
      <div className="text-center mb-12">
        <h1 className="text-6xl font-bold text-gray-800 mb-4">
          HealthChat AI
        </h1>
        <p className="text-xl text-gray-600">
          Interactive Medical Assistant with 3D Anatomy Visualization
        </p>
      </div>

      <div className="grid md:grid-cols-2 gap-8 max-w-4xl w-full">
        {/* Patient Mode */}
        <div
          onClick={() => navigate('/patient')}
          className="bg-white rounded-2xl shadow-xl p-8 cursor-pointer transform transition-all duration-300 hover:scale-105 hover:shadow-2xl border-4 border-transparent hover:border-blue-400"
        >
          <div className="flex flex-col items-center">
            <div className="bg-blue-100 p-6 rounded-full mb-6">
              <FaUser className="text-6xl text-blue-600" />
            </div>
            <h2 className="text-3xl font-bold text-gray-800 mb-4">
              Patient Mode
            </h2>
            <p className="text-gray-600 text-center mb-6">
              Upload your medical reports, understand your results through AI-powered voice chat, and explore 3D anatomy
            </p>
            <ul className="text-left text-gray-600 space-y-2">
              <li>• Upload medical reports & test results</li>
              <li>• Voice conversation with AI</li>
              <li>• Interactive 3D anatomy visualization</li>
              <li>• Home remedies & precautions</li>
              <li>• Symptom video analysis</li>
            </ul>
          </div>
        </div>

        {/* Doctor Mode */}
        <div
          onClick={() => navigate('/doctor')}
          className="bg-white rounded-2xl shadow-xl p-8 cursor-pointer transform transition-all duration-300 hover:scale-105 hover:shadow-2xl border-4 border-transparent hover:border-green-400"
        >
          <div className="flex flex-col items-center">
            <div className="bg-green-100 p-6 rounded-full mb-6">
              <FaUserMd className="text-6xl text-green-600" />
            </div>
            <h2 className="text-3xl font-bold text-gray-800 mb-4">
              Doctor Mode
            </h2>
            <p className="text-gray-600 text-center mb-6">
              Advanced clinical tools, patient history analysis, and detailed 3D surgical planning assistance
            </p>
            <ul className="text-left text-gray-600 space-y-2">
              <li>• Patient history & multi-report analysis</li>
              <li>• Detailed clinical insights</li>
              <li>• Surgery planning with 3D models</li>
              <li>• Advanced anatomy navigation</li>
              <li>• Treatment recommendations</li>
            </ul>
          </div>
        </div>
      </div>

      <div className="mt-12 text-center text-gray-500">
        <p>Powered by AI • BioDigital Human • Voice Interface</p>
      </div>
    </div>
  )
}

export default HomePage
