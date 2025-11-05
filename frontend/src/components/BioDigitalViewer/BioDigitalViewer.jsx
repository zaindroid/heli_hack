import { useEffect, useRef, useState } from 'react'

function BioDigitalViewer({ onHumanReady, mode = 'patient' }) {
  const iframeRef = useRef(null)
  const humanRef = useRef(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    initializeBioDigital()
  }, [])

  const initializeBioDigital = () => {
    try {
      const apiKey = import.meta.env.VITE_BIODIGITAL_API_KEY

      if (!apiKey) {
        setError('BioDigital API key not found')
        setIsLoading(false)
        return
      }

      // Initialize BioDigital Human
      const human = new window.HumanAPI({
        containerId: 'biodigital-iframe',
        key: apiKey,
        background: '#1a1a2e',
        ui: {
          info: true,
          help: false,
          fullscreen: true,
          zoom: true,
          annotations: true,
        },
      })

      human.on('human.ready', () => {
        console.log('BioDigital Human ready')
        humanRef.current = human
        setIsLoading(false)

        // Call parent callback
        if (onHumanReady) {
          onHumanReady(human)
        }
      })

      human.on('error', (err) => {
        console.error('BioDigital error:', err)
        setError('Failed to load 3D model')
        setIsLoading(false)
      })

    } catch (err) {
      console.error('Error initializing BioDigital:', err)
      setError('Failed to initialize viewer')
      setIsLoading(false)
    }
  }

  // Expose methods for AI control
  useEffect(() => {
    if (humanRef.current && window) {
      window.biodigitalHuman = humanRef.current
    }
  }, [humanRef.current])

  return (
    <div className="relative w-full h-full bg-gray-900 rounded-lg overflow-hidden">
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-900 z-10">
          <div className="text-center">
            <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-blue-500 mx-auto mb-4"></div>
            <p className="text-white text-lg">Loading 3D Anatomy Model...</p>
          </div>
        </div>
      )}

      {error && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-900 z-10">
          <div className="text-center text-red-500">
            <p className="text-xl">{error}</p>
          </div>
        </div>
      )}

      <div
        id="biodigital-iframe"
        ref={iframeRef}
        className="w-full h-full"
        style={{ minHeight: '600px' }}
      />
    </div>
  )
}

export default BioDigitalViewer
