# BioDigital HTTPS Requirement Fix

## Problem

BioDigital Human API **requires HTTPS** to load 3D models. Opening the test file with `file://` protocol doesn't work.

From BioDigital documentation:
> **Important:** To load 3D models in the Human Viewer, your site must be served over a secure connection (i.e., HTTPS). If your site is not secure, your models may fail to load or behave unpredictably.

## Solution

Serve the test file over HTTPS using a local development server.

## Quick Test (HTTPS)

```bash
# Start HTTPS server
./serve-test-https.sh
```

Then open in your **Windows browser**:
```
https://localhost:8443/test-biodigital.html
```

**Note:** You'll see a security warning because we use a self-signed certificate. This is safe for local testing.
- Click "Advanced"
- Click "Proceed to localhost (unsafe)" or "Accept the Risk and Continue"

## Alternative: HTTP Test (may not work)

BioDigital requires HTTPS, but you can try HTTP to confirm it's the protocol issue:

```bash
# Start HTTP server
./serve-test.sh
```

Then open:
```
http://localhost:8080/test-biodigital.html
```

If this fails with the same issue, it confirms HTTPS is required.

## For Full Application

The full HealthChat AI app uses Vite dev server which supports HTTPS. To enable:

1. Install mkcert for local HTTPS:
```bash
# On WSL Ubuntu
sudo apt install libnss3-tools
wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
chmod +x mkcert
sudo mv mkcert /usr/local/bin/
mkcert -install
```

2. Create certificates:
```bash
cd frontend
mkcert localhost 127.0.0.1 ::1
```

3. Update `vite.config.js`:
```javascript
export default defineConfig({
  server: {
    https: {
      key: fs.readFileSync('localhost-key.pem'),
      cert: fs.readFileSync('localhost.pem'),
    },
    port: 5173
  }
})
```

4. Start with HTTPS:
```bash
npm run dev
```

Access at: `https://localhost:5173`

## Why This Matters

- BioDigital's 3D models load from their servers over HTTPS
- Mixed content (HTTPS → HTTP) is blocked by browsers
- Local file:// protocol has no SSL/TLS
- Therefore, we must serve over HTTPS

## Troubleshooting

**Issue:** "NET::ERR_CERT_AUTHORITY_INVALID"
- **Solution:** Click "Advanced" → "Proceed to localhost"
- This is expected with self-signed certificates

**Issue:** Server won't start (port in use)
- **Solution:** Kill existing server: `pkill -f "python3 -m http.server"`

**Issue:** Can't access from Windows browser
- **Solution:** Use `localhost`, not `127.0.0.1` or WSL IP
- Windows can access WSL's localhost directly
