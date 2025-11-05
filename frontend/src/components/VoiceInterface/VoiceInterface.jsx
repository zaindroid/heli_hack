import { useState, useEffect, useRef } from 'react'
import { FaMicrophone, FaMicrophoneSlash, FaVolumeUp } from 'react-icons/fa'

function VoiceInterface({ human, mode, onVoiceStateChange }) {
  const [isConnected, setIsConnected] = useState(false)
  const [isListening, setIsListening] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)
  const [messages, setMessages] = useState([])
  const [status, setStatus] = useState('Disconnected')
  const wsRef = useRef(null)
  const messagesEndRef = useRef(null)

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const connectToAgent = async () => {
    try {
      setStatus('Connecting...')

      // WebSocket connection to backend Pipecat agent
      const wsUrl = import.meta.env.VITE_WS_URL || 'ws://localhost:8000'
      const ws = new WebSocket(`${wsUrl}/ws/voice?mode=${mode}`)

      ws.onopen = () => {
        console.log('Connected to voice agent')
        setIsConnected(true)
        setStatus('Connected')
        addMessage('system', 'Voice assistant connected. Click microphone to start.')
      }

      ws.onmessage = (event) => {
        const data = JSON.parse(event.data)
        handleAgentMessage(data)
      }

      ws.onerror = (error) => {
        console.error('WebSocket error:', error)
        setStatus('Connection Error')
        addMessage('system', 'Connection error. Please try again.')
      }

      ws.onclose = () => {
        console.log('Disconnected from voice agent')
        setIsConnected(false)
        setStatus('Disconnected')
        setIsListening(false)
        setIsSpeaking(false)
      }

      wsRef.current = ws
    } catch (error) {
      console.error('Failed to connect:', error)
      setStatus('Failed to connect')
    }
  }

  const disconnect = () => {
    if (wsRef.current) {
      wsRef.current.close()
      wsRef.current = null
    }
    setIsConnected(false)
    setIsListening(false)
    setIsSpeaking(false)
  }

  const toggleListening = () => {
    if (!isConnected) {
      connectToAgent()
      return
    }

    const newState = !isListening
    setIsListening(newState)

    if (onVoiceStateChange) {
      onVoiceStateChange(newState)
    }

    // Send control message to backend
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(
        JSON.stringify({
          type: 'control',
          action: newState ? 'start_listening' : 'stop_listening',
        })
      )
    }

    if (newState) {
      addMessage('system', 'Listening...')
    }
  }

  const handleAgentMessage = (data) => {
    switch (data.type) {
      case 'transcript':
        // User's speech transcription
        addMessage('user', data.text)
        break

      case 'ai_response':
        // AI's text response
        addMessage('assistant', data.text)
        break

      case 'speaking_start':
        setIsSpeaking(true)
        break

      case 'speaking_end':
        setIsSpeaking(false)
        break

      case 'anatomy_control':
        // AI is controlling the 3D model
        if (human) {
          executeAnatomyControl(data.action, data.params)
        }
        break

      case 'error':
        addMessage('system', `Error: ${data.message}`)
        break

      default:
        console.log('Unknown message type:', data)
    }
  }

  const executeAnatomyControl = async (action, params) => {
    if (!human) return

    try {
      switch (action) {
        case 'navigate_to':
          await human.camera.flyTo({ id: params.organId, duration: 1.5 })
          break

        case 'zoom':
          await human.camera.zoom(params.level)
          break

        case 'highlight':
          await human.scene.pick({ id: params.structureId })
          break

        case 'play_animation':
          await human.timeline.play({ animation: params.animationName })
          break

        case 'rotate':
          await human.camera.rotate({
            angle: params.angle,
            axis: params.axis
          })
          break

        default:
          console.log('Unknown anatomy control:', action)
      }
    } catch (error) {
      console.error('Error controlling anatomy:', error)
    }
  }

  const addMessage = (role, text) => {
    setMessages((prev) => [
      ...prev,
      { role, text, timestamp: new Date().toISOString() },
    ])
  }

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-800">
          AI Voice Assistant
        </h3>
        <div className="flex items-center space-x-2">
          <div
            className={`w-3 h-3 rounded-full ${
              isConnected ? 'bg-green-500' : 'bg-red-500'
            }`}
          />
          <span className="text-sm text-gray-600">{status}</span>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto bg-gray-50 rounded-lg p-4 mb-4 space-y-3">
        {messages.length === 0 && (
          <div className="text-center text-gray-400 mt-8">
            <p>No messages yet</p>
            <p className="text-sm mt-2">
              Connect and start speaking to interact with AI
            </p>
          </div>
        )}

        {messages.map((msg, index) => (
          <div
            key={index}
            className={`flex ${
              msg.role === 'user' ? 'justify-end' : 'justify-start'
            }`}
          >
            <div
              className={`max-w-[80%] rounded-lg px-4 py-2 ${
                msg.role === 'user'
                  ? 'bg-blue-500 text-white'
                  : msg.role === 'assistant'
                  ? mode === 'patient'
                    ? 'bg-white border-2 border-blue-300 text-gray-800'
                    : 'bg-white border-2 border-green-300 text-gray-800'
                  : 'bg-gray-200 text-gray-600 text-sm'
              }`}
            >
              {msg.text}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Controls */}
      <div className="flex items-center justify-center space-x-4">
        <button
          onClick={toggleListening}
          disabled={!isConnected && isListening}
          className={`p-6 rounded-full transition-all transform hover:scale-110 ${
            isListening
              ? 'bg-red-500 hover:bg-red-600 animate-pulse'
              : isConnected
              ? mode === 'patient'
                ? 'bg-blue-500 hover:bg-blue-600'
                : 'bg-green-500 hover:bg-green-600'
              : 'bg-gray-400 hover:bg-gray-500'
          }`}
        >
          {isListening ? (
            <FaMicrophone className="text-white text-3xl" />
          ) : (
            <FaMicrophoneSlash className="text-white text-3xl" />
          )}
        </button>

        {isSpeaking && (
          <div className="flex items-center space-x-2 text-gray-600">
            <FaVolumeUp className="animate-pulse" />
            <span className="text-sm">AI is speaking...</span>
          </div>
        )}

        {isConnected && (
          <button
            onClick={disconnect}
            className="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition"
          >
            Disconnect
          </button>
        )}
      </div>

      <div className="mt-4 text-xs text-gray-500 text-center">
        {isListening
          ? 'Speak now... AI is listening'
          : isConnected
          ? 'Click microphone to start speaking'
          : 'Click microphone to connect'}
      </div>
    </div>
  )
}

export default VoiceInterface
