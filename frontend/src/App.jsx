import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomePage from './components/HomePage'
import PatientMode from './components/PatientMode/PatientMode'
import DoctorMode from './components/DoctorMode/DoctorMode'

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/patient" element={<PatientMode />} />
          <Route path="/doctor" element={<DoctorMode />} />
        </Routes>
      </div>
    </Router>
  )
}

export default App
