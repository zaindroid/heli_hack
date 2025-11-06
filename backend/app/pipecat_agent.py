"""
Pipecat AI Agent for HealthChat
Handles voice interaction, anatomy navigation, and medical insights
"""

import os
import json
import logging
from typing import Optional
from pathlib import Path
from openai import AsyncOpenAI

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Load anatomy database
ANATOMY_DB_PATH = Path(__file__).parent / "anatomy_data.json"
with open(ANATOMY_DB_PATH, 'r') as f:
    ANATOMY_DATABASE = json.load(f)


# Anatomy control tools for function calling - based on user's database
ANATOMY_TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "load_anatomy_model",
            "description": "Load a specific 3D anatomy model. Available models: 'neck_shoulders_upper_back' (for neck pain, shoulder issues), 'skeletal_system' (for bone structure)",
            "parameters": {
                "type": "object",
                "properties": {
                    "model_id": {
                        "type": "string",
                        "description": "The ID of the model to load",
                        "enum": ["neck_shoulders_upper_back", "skeletal_system"]
                    },
                    "reason": {
                        "type": "string",
                        "description": "Why this model is relevant to the conversation"
                    }
                },
                "required": ["model_id", "reason"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "navigate_to_viewpoint",
            "description": "Move camera to a specific anatomical viewpoint. For neck model: 'front', 'back', 'left_shoulder', 'right_shoulder'. For skeletal: 'front', 'side', 'head', 'legs'",
            "parameters": {
                "type": "object",
                "properties": {
                    "model_id": {
                        "type": "string",
                        "description": "The current model ID",
                        "enum": ["neck_shoulders_upper_back", "skeletal_system"]
                    },
                    "viewpoint_id": {
                        "type": "string",
                        "description": "The viewpoint to navigate to (e.g., 'front', 'back', 'left_shoulder', 'right_shoulder')"
                    },
                    "explanation": {
                        "type": "string",
                        "description": "Explain why showing this view"
                    }
                },
                "required": ["model_id", "viewpoint_id", "explanation"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "highlight_muscle_group",
            "description": "Highlight a group of muscles for pain areas. Available groups: 'neck_knots' (trapezius, levator scapulae), 'shoulder_pain' (rotator cuff), 'upper_back' (trapezius, rhomboids)",
            "parameters": {
                "type": "object",
                "properties": {
                    "group_id": {
                        "type": "string",
                        "description": "The muscle group to highlight",
                        "enum": ["neck_knots", "shoulder_pain", "upper_back"]
                    },
                    "explanation": {
                        "type": "string",
                        "description": "Why highlighting these muscles"
                    }
                },
                "required": ["group_id", "explanation"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "highlight_custom_muscle",
            "description": "Highlight a specific muscle by name (e.g., 'left trapezius', 'right deltoid', 'sternocleidomastoid')",
            "parameters": {
                "type": "object",
                "properties": {
                    "muscle_name": {
                        "type": "string",
                        "description": "Name of the muscle to highlight"
                    }
                },
                "required": ["muscle_name"]
            }
        }
    }
]


class HealthChatAgent:
    """AI Agent for health conversations with anatomy navigation"""

    def __init__(self, mode: str = "patient"):
        self.mode = mode
        self.conversation_history = []
        self.patient_context = {}

        # Set system prompt based on mode
        if mode == "patient":
            self.system_prompt = """You are a helpful medical AI assistant for patients.
Your role is to:
1. Explain medical test results in simple, easy-to-understand language
2. Navigate the 3D anatomy model to show relevant body parts
3. Provide home care tips and when to see a doctor
4. Answer health questions with empathy and clarity
5. Use the anatomy visualization tools to make explanations visual and engaging

Always be supportive, clear, and avoid medical jargon. When discussing health issues,
use the 3D anatomy navigation functions to show patients what you're talking about.

IMPORTANT: Call the anatomy navigation functions proactively to enhance explanations."""

        else:  # doctor mode
            self.system_prompt = """You are an advanced clinical AI assistant for healthcare professionals.
Your role is to:
1. Provide detailed analysis of patient reports and medical data
2. Navigate 3D anatomy models for surgical planning and patient education
3. Offer evidence-based clinical insights and treatment options
4. Assist with differential diagnosis based on symptoms and test results
5. Use precise medical terminology and reference clinical guidelines

Use the 3D anatomy visualization tools to support clinical decision-making and
surgical planning. Provide detailed, professional medical information."""

        self.conversation_history.append({
            "role": "system",
            "content": self.system_prompt
        })

    async def process_message(self, user_message: str, websocket=None):
        """Process user message and generate response with function calling"""

        # Add user message to history
        self.conversation_history.append({
            "role": "user",
            "content": user_message
        })

        try:
            # Call OpenAI with function calling
            response = await client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=self.conversation_history,
                tools=ANATOMY_TOOLS,
                tool_choice="auto",
                temperature=0.7,
                max_tokens=500
            )

            assistant_message = response.choices[0].message

            # Handle function calls
            if assistant_message.tool_calls:
                for tool_call in assistant_message.tool_calls:
                    function_name = tool_call.function.name
                    function_args = json.loads(tool_call.function.arguments)

                    logger.info(f"AI calling function: {function_name} with args: {function_args}")

                    # Send anatomy control to frontend
                    if websocket:
                        await self.send_anatomy_control(
                            websocket,
                            function_name,
                            function_args
                        )

            # Get text response
            response_text = assistant_message.content or ""

            # Add assistant response to history
            self.conversation_history.append({
                "role": "assistant",
                "content": response_text
            })

            return response_text

        except Exception as e:
            logger.error(f"Error processing message: {e}")
            return f"I apologize, I encountered an error: {str(e)}"

    async def send_anatomy_control(self, websocket, function_name, args):
        """Send anatomy control command to frontend based on anatomy database"""

        try:
            if function_name == "load_anatomy_model":
                # Find model in database
                model_id = args.get("model_id")
                model_data = next(
                    (m for m in ANATOMY_DATABASE["models"] if m["id"] == model_id),
                    None
                )

                if model_data:
                    logger.info(f"Loading model: {model_data['name']}")
                    await websocket.send_json({
                        "type": "load_model",
                        "model": model_data,
                        "reason": args.get("reason")
                    })

            elif function_name == "navigate_to_viewpoint":
                # Find viewpoint in database
                model_id = args.get("model_id")
                viewpoint_id = args.get("viewpoint_id")

                model = next(
                    (m for m in ANATOMY_DATABASE["models"] if m["id"] == model_id),
                    None
                )

                if model:
                    viewpoint = next(
                        (v for v in model["viewpoints"] if v["id"] == viewpoint_id),
                        None
                    )

                    if viewpoint:
                        logger.info(f"Navigating to viewpoint: {viewpoint['name']}")
                        await websocket.send_json({
                            "type": "camera_navigate",
                            "camera": viewpoint["camera"],
                            "viewpoint_name": viewpoint["name"],
                            "explanation": args.get("explanation")
                        })

            elif function_name == "highlight_muscle_group":
                # Define muscle groups based on anatomy database
                muscle_groups = {
                    "neck_knots": ["Trapezius", "Levator scapulae", "Sternocleidomastoid"],
                    "shoulder_pain": ["Deltoid", "Supraspinatus", "Infraspinatus", "Rotator cuff muscles"],
                    "upper_back": ["Trapezius", "Rhomboids", "Latissimus dorsi"]
                }

                group_id = args.get("group_id")
                muscles = muscle_groups.get(group_id, [])

                logger.info(f"Highlighting muscle group: {group_id}")
                await websocket.send_json({
                    "type": "highlight_muscles",
                    "muscles": muscles,
                    "group_id": group_id,
                    "explanation": args.get("explanation")
                })

            elif function_name == "highlight_custom_muscle":
                muscle_name = args.get("muscle_name")

                logger.info(f"Highlighting muscle: {muscle_name}")
                await websocket.send_json({
                    "type": "highlight_muscle",
                    "muscle": muscle_name
                })

        except Exception as e:
            logger.error(f"Error sending anatomy control: {e}")
            await websocket.send_json({
                "type": "error",
                "message": f"Failed to control anatomy: {str(e)}"
            })

    def add_patient_context(self, context: dict):
        """Add patient information or medical reports to context"""
        self.patient_context.update(context)

        # Add context to conversation
        context_message = f"Patient context updated: {json.dumps(context, indent=2)}"
        self.conversation_history.append({
            "role": "system",
            "content": context_message
        })


async def create_agent(mode: str = "patient") -> HealthChatAgent:
    """Create and initialize a new agent"""
    agent = HealthChatAgent(mode=mode)
    logger.info(f"Created new HealthChat agent in {mode} mode")
    return agent


async def handle_voice_interaction(agent: HealthChatAgent, text: str, websocket):
    """Handle a voice interaction with the agent"""

    try:
        # Send transcript to client
        await websocket.send_json({
            "type": "transcript",
            "text": text
        })

        # Process with agent
        response = await agent.process_message(text, websocket)

        # Send AI response
        await websocket.send_json({
            "type": "ai_response",
            "text": response
        })

        # TODO: Convert response to speech with Deepgram/ElevenLabs
        # For now, just indicate speaking
        await websocket.send_json({"type": "speaking_start"})
        # Simulate speaking delay
        import asyncio
        await asyncio.sleep(len(response) * 0.05)  # Rough estimate
        await websocket.send_json({"type": "speaking_end"})

        return response

    except Exception as e:
        logger.error(f"Error in voice interaction: {e}")
        await websocket.send_json({
            "type": "error",
            "message": str(e)
        })
        return None
