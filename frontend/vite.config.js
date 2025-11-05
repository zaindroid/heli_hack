import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import basicSsl from '@vitejs/plugin-basic-ssl'

// Plugin to set CSP headers for BioDigital API
const cspPlugin = () => ({
  name: 'csp-plugin',
  configureServer(server) {
    server.middlewares.use((req, res, next) => {
      // Remove any existing CSP headers
      res.removeHeader('Content-Security-Policy')
      res.removeHeader('Content-Security-Policy-Report-Only')
      // Don't set CSP - let BioDigital API work without restrictions in dev
      next()
    })
  }
})

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    basicSsl(),  // Enables HTTPS with self-signed certificate for BioDigital API
    cspPlugin()  // Disable CSP in dev mode for BioDigital API
  ],
  server: {
    port: 5173,
    host: true,
    https: true,  // Required by BioDigital Human API
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/ws': {
        target: 'ws://localhost:8000',
        ws: true,
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  }
})
