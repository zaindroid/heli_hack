import { useEffect, useRef, useState } from 'react'

function BioDigitalViewer({ onHumanReady, mode = 'patient' }) {
  const humanRef = useRef(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)
  const [debugInfo, setDebugInfo] = useState('')

  useEffect(() => {
    // Wait for HumanAPI script to load
    const checkAndInitialize = () => {
      if (window.HumanAPI) {
        initializeBioDigital()
      } else {
        // Wait for script to load
        const checkHumanAPI = setInterval(() => {
          if (window.HumanAPI) {
            clearInterval(checkHumanAPI)
            initializeBioDigital()
          }
        }, 100)

        // Timeout after 10 seconds
        setTimeout(() => {
          clearInterval(checkHumanAPI)
          if (!window.HumanAPI) {
            setError('BioDigital Human API script failed to load')
            setIsLoading(false)
            setDebugInfo('Make sure you have internet connection and the script can load')
          }
        }, 10000)
      }
    }

    // Small delay to ensure iframe is rendered
    setTimeout(checkAndInitialize, 500)
  }, [])

  const initializeBioDigital = () => {
    try {
      console.log('Initializing BioDigital Human...')
      console.log('Using user account authentication (uaid/paid)')

      // Check if HumanAPI is available
      if (!window.HumanAPI) {
        setError('BioDigital Human API not loaded')
        setIsLoading(false)
        setDebugInfo('HumanAPI constructor not found. Check if script loaded correctly.')
        console.error('window.HumanAPI is not defined')
        return
      }

      console.log('Creating HumanAPI.Human instance...')

      // Initialize using the correct method: pass iframe ID
      const human = new window.HumanAPI('biodigital-iframe')

      console.log('HumanAPI.Human instance created:', human)

      // Listen for ready event (note: it's 'ready', not 'human.ready')
      human.on('ready', () => {
        console.log('✓ BioDigital Human ready!')
        humanRef.current = human
        setIsLoading(false)
        setError(null)

        // Call parent callback
        if (onHumanReady) {
          onHumanReady(human)
        }
      })

      human.on('error', (err) => {
        console.error('BioDigital error event:', err)
        setError('Failed to load 3D model')
        setIsLoading(false)

        // More specific error messages
        if (err.message) {
          setDebugInfo(`Error: ${err.message}`)
        } else if (err.code === 401) {
          setDebugInfo('Invalid API key. Check your BioDigital API key.')
        } else {
          setDebugInfo('Check console for details. Make sure API key is valid.')
        }
      })

    } catch (err) {
      console.error('Error initializing BioDigital:', err)
      setError('Failed to initialize viewer')
      setIsLoading(false)
      setDebugInfo(`Exception: ${err.message}`)
    }
  }

  // Expose methods for AI control
  useEffect(() => {
    if (humanRef.current && window) {
      window.biodigitalHuman = humanRef.current
      console.log('BioDigital Human exposed to window.biodigitalHuman')
    }
  }, [humanRef.current])

  // Get the iframe src with model and developer key
  const getIframeSrc = () => {
    // Use PUBLIC model with developer key for SDK access
    // Model 6cr6 is private and only accessible with user auth, not developer key
    const modelId = 'production/maleAdult/male_region_0'  // Public male anatomy model
    const developerKey = 'c0c3685a4e0996e0095ae1a7d7cb46079b9db70a'  // Developer key for SDK access

    // Use /widget/ endpoint with developer key (enables JavaScript SDK)
    return `https://human.biodigital.com/widget/?m=${modelId}&dk=${developerKey}&ui-info=true&ui-zoom=true&ui-nav=true&ui-tools=true&ui-layers=true&ui-menu=true&ui-search=true&background=1a1a2e&initial.none=true`
  }

  return (
    <div className="relative w-full h-full bg-gray-900 rounded-lg overflow-hidden">
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-900 z-10">
          <div className="text-center">
            <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-blue-500 mx-auto mb-4"></div>
            <p className="text-white text-lg">Loading 3D Anatomy Model...</p>
            <p className="text-gray-400 text-sm mt-2">This may take 10-15 seconds...</p>
          </div>
        </div>
      )}

      {error && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-900 z-10 p-8">
          <div className="text-center max-w-md">
            <div className="text-red-500 mb-4">
              <svg className="w-16 h-16 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <p className="text-xl font-bold mb-2">{error}</p>
            </div>

            {debugInfo && (
              <div className="bg-gray-800 p-4 rounded-lg text-left mb-4">
                <p className="text-yellow-400 text-sm font-mono">{debugInfo}</p>
              </div>
            )}

            <div className="text-gray-400 text-sm space-y-2">
              <p>Possible solutions:</p>
              <ul className="list-disc text-left pl-5 space-y-1">
                <li>Check if VITE_BIODIGITAL_API_KEY is set in frontend/.env</li>
                <li>Verify your API key is valid at <a href="https://human.biodigital.com" className="text-blue-400 hover:underline" target="_blank" rel="noopener noreferrer">BioDigital Human</a></li>
                <li>Make sure you have internet connection</li>
                <li>Check browser console (F12) for more details</li>
              </ul>
            </div>

            <button
              onClick={() => {
                setError(null)
                setIsLoading(true)
                setDebugInfo('')
                setTimeout(() => initializeBioDigital(), 500)
              }}
              className="mt-6 bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition"
            >
              Try Again
            </button>
          </div>
        </div>
      )}

      {/* The iframe that hosts the BioDigital widget */}
      <iframe
        id="biodigital-iframe"
        src={getIframeSrc()}
        className="w-full h-full border-0"
        style={{ minHeight: '600px' }}
        allow="fullscreen"
      />
    </div>
  )
}

export default BioDigitalViewer
