from fastapi import FastAPI, WebSocket, WebSocketDisconnect, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
import os
import logging

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI
app = FastAPI(
    title="HealthChat AI API",
    description="AI-Powered Healthcare Data Explorer with Voice Interface",
    version="1.0.0"
)

# CORS Configuration
origins = os.getenv("CORS_ORIGINS", "http://localhost:5173").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store active connections
active_connections: dict[str, WebSocket] = {}


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "HealthChat AI",
        "version": "1.0.0"
    }


@app.get("/api/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "deepgram": "configured" if os.getenv("DEEPGRAM_API_KEY") else "missing",
        "openai": "configured" if os.getenv("OPENAI_API_KEY") else "missing",
        "biodigital": "configured" if os.getenv("BIODIGITAL_API_KEY") else "missing",
    }


@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    """Upload medical reports for processing"""
    try:
        # Create uploads directory if it doesn't exist
        os.makedirs("uploads", exist_ok=True)

        # Save file
        file_path = f"uploads/{file.filename}"
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # TODO: Process file (extract text, analyze)

        return {
            "status": "success",
            "filename": file.filename,
            "size": len(content),
            "message": "File uploaded successfully"
        }
    except Exception as e:
        logger.error(f"Error uploading file: {e}")
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )


@app.websocket("/ws/voice")
async def voice_websocket(websocket: WebSocket, mode: str = "patient"):
    """
    WebSocket endpoint for voice interaction with Pipecat agent
    """
    await websocket.accept()
    connection_id = id(websocket)
    active_connections[connection_id] = websocket

    logger.info(f"New voice connection: {connection_id} (mode: {mode})")

    try:
        # Import and initialize Pipecat agent
        from .pipecat_agent import create_agent, handle_voice_interaction

        # Create agent for this session
        agent = await create_agent(mode=mode)

        # Send welcome message
        await websocket.send_json({
            "type": "system",
            "message": f"Connected to HealthChat AI ({mode} mode)"
        })

        # Handle messages
        while True:
            try:
                # Receive message from client
                data = await websocket.receive_json()

                # Process based on message type
                if data.get("type") == "control":
                    action = data.get("action")

                    if action == "start_listening":
                        logger.info("Starting voice listening...")
                        # Start listening logic here
                        await websocket.send_json({
                            "type": "system",
                            "message": "Listening started"
                        })

                    elif action == "stop_listening":
                        logger.info("Stopping voice listening...")
                        await websocket.send_json({
                            "type": "system",
                            "message": "Listening stopped"
                        })

                elif data.get("type") == "audio":
                    # Handle audio data from client
                    # TODO: Process with Deepgram and Pipecat
                    pass

                elif data.get("type") == "text":
                    # Handle text input (for testing without voice)
                    text = data.get("text", "")
                    response = await handle_voice_interaction(agent, text, websocket)

            except WebSocketDisconnect:
                logger.info(f"Client disconnected: {connection_id}")
                break
            except Exception as e:
                logger.error(f"Error in WebSocket loop: {e}")
                await websocket.send_json({
                    "type": "error",
                    "message": str(e)
                })

    except Exception as e:
        logger.error(f"WebSocket error: {e}")

    finally:
        # Clean up
        if connection_id in active_connections:
            del active_connections[connection_id]
        logger.info(f"Connection closed: {connection_id}")


@app.post("/api/analyze-report")
async def analyze_report(file_path: str):
    """Analyze uploaded medical report"""
    try:
        from .report_parser import parse_report

        analysis = await parse_report(file_path)

        return {
            "status": "success",
            "analysis": analysis
        }
    except Exception as e:
        logger.error(f"Error analyzing report: {e}")
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )


if __name__ == "__main__":
    import uvicorn

    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))

    uvicorn.run(
        "app.main:app",
        host=host,
        port=port,
        reload=True,
        log_level="info"
    )
