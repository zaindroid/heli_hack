import { useEffect, useRef, useState } from 'react'

function BioDigitalViewer({ onHumanReady, mode = 'patient', currentModel = null }) {
  const humanRef = useRef(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)
  const [debugInfo, setDebugInfo] = useState('')
  const [loadedModel, setLoadedModel] = useState(null)

  useEffect(() => {
    // Using public model with developer key for SDK access
    const checkAndInitialize = () => {
      if (window.HumanAPI) {
        initializeBioDigital()
      } else {
        const checkHumanAPI = setInterval(() => {
          if (window.HumanAPI) {
            clearInterval(checkHumanAPI)
            initializeBioDigital()
          }
        }, 100)

        setTimeout(() => {
          clearInterval(checkHumanAPI)
          if (!window.HumanAPI) {
            setError('BioDigital Human API script failed to load')
            setIsLoading(false)
            setDebugInfo('Make sure you have internet connection')
          }
        }, 10000)
      }
    }

    setTimeout(checkAndInitialize, 500)
  }, [])

  const initializeBioDigital = () => {
    try {
      console.log('Initializing BioDigital Human using documentation format...')

      // Check if HumanAPI is available
      if (!window.HumanAPI) {
        setError('BioDigital Human API not loaded')
        setIsLoading(false)
        setDebugInfo('HumanAPI constructor not found. Check if script loaded correctly.')
        console.error('window.HumanAPI is not defined')
        return
      }

      console.log('Creating HumanAPI instance (docs format)...')

      // Initialize EXACTLY as shown in documentation
      const human = new window.HumanAPI('biodigital-iframe')

      console.log('HumanAPI instance created:', human)

      // Listen for ready event as shown in docs
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

  // Handle model switching when currentModel prop changes
  useEffect(() => {
    if (currentModel && loadedModel !== currentModel.id) {
      console.log('Switching to model:', currentModel.name)
      setLoadedModel(currentModel.id)
      setIsLoading(true)

      // Reload iframe with new model
      const iframe = document.getElementById('biodigital-iframe')
      if (iframe) {
        iframe.src = getIframeSrc()
      }
    }
  }, [currentModel])

  // Get the iframe src with user's library model and uaid/paid authentication
  const getIframeSrc = () => {
    // Use provided model or default to neck/shoulders model
    const modelId = currentModel?.id || '6cr6'  // User's neck, shoulders & upper back model

    // User's authentication credentials for library models
    const uaid = 'ML3xE'
    const paid = 'o_22e32b94'

    // Format: /viewer/?id=MODEL&uaid=X&paid=Y (works with SDK as shown in user's test.html)
    const url = `https://human.biodigital.com/viewer/?id=${modelId}&ui-anatomy-descriptions=true&ui-anatomy-pronunciations=true&ui-anatomy-labels=true&ui-audio=true&ui-chapter-list=false&ui-fullscreen=true&ui-help=true&ui-info=true&ui-label-list=true&ui-layers=true&ui-skin-layers=true&ui-loader=circle&ui-media-controls=full&ui-menu=true&ui-nav=true&ui-search=true&ui-tools=true&ui-tutorial=false&ui-undo=true&ui-whiteboard=true&initial.none=true&disable-scroll=false&uaid=${uaid}&paid=${paid}`

    console.log('BioDigital iframe URL (library model):', url)
    return url
  }

  // Camera navigation function (from user's test.html pattern)
  const navigateToViewpoint = (camera) => {
    if (!humanRef.current) {
      console.error('Human API not initialized')
      return
    }

    humanRef.current.send('camera.set', {
      position: camera.position,
      target: camera.target,
      animate: true,
      duration: 1000
    })
  }

  // Highlight single muscle (from user's test.html pattern)
  const highlightMuscle = (muscleName) => {
    if (!humanRef.current) {
      console.error('Human API not initialized')
      return
    }

    console.log('Highlighting muscle:', muscleName)

    // Show and select the muscle
    humanRef.current.send('object.show', { objectId: muscleName })
    humanRef.current.send('object.select', { objectId: muscleName, replace: false })
    humanRef.current.send('object.setOpacity', { objectId: muscleName, opacity: 1.0 })

    // Make it red to highlight
    humanRef.current.send('object.setMaterial', {
      objectId: muscleName,
      material: {
        diffuse: { r: 1.0, g: 0.0, b: 0.0 }
      }
    })
  }

  // Highlight multiple muscles
  const highlightMuscles = (muscleNames) => {
    if (!Array.isArray(muscleNames)) {
      muscleNames = [muscleNames]
    }

    muscleNames.forEach(muscle => {
      highlightMuscle(muscle)
    })
  }

  // Expose control methods
  useEffect(() => {
    if (humanRef.current) {
      window.biodigitalControls = {
        human: humanRef.current,
        navigateToViewpoint,
        highlightMuscle,
        highlightMuscles
      }
      console.log('BioDigital controls exposed to window.biodigitalControls')
    }
  }, [humanRef.current])

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
