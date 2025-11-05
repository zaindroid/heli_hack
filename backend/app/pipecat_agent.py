"""
Pipecat AI Agent for HealthChat
Handles voice interaction, anatomy navigation, and medical insights
"""

import os
import json
import logging
from typing import Optional
from openai import AsyncOpenAI

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))


# Anatomy control tools for function calling
ANATOMY_TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "navigate_to_organ",
            "description": "Navigate the 3D anatomy viewer to a specific organ or body part",
            "parameters": {
                "type": "object",
                "properties": {
                    "organ_id": {
                        "type": "string",
                        "description": "The ID of the organ to navigate to (e.g., 'heart', 'lungs', 'liver', 'brain')"
                    },
                    "explanation": {
                        "type": "string",
                        "description": "Brief explanation of why navigating to this organ"
                    }
                },
                "required": ["organ_id", "explanation"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "zoom_anatomy",
            "description": "Zoom in or out on the 3D anatomy model",
            "parameters": {
                "type": "object",
                "properties": {
                    "level": {
                        "type": "number",
                        "description": "Zoom level (1-5, where 1 is furthest, 5 is closest)"
                    }
                },
                "required": ["level"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "highlight_structure",
            "description": "Highlight a specific anatomical structure in the 3D model",
            "parameters": {
                "type": "object",
                "properties": {
                    "structure_id": {
                        "type": "string",
                        "description": "The ID of the structure to highlight"
                    }
                },
                "required": ["structure_id"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "play_animation",
            "description": "Play a built-in animation showing a biological process",
            "parameters": {
                "type": "object",
                "properties": {
                    "animation_name": {
                        "type": "string",
                        "description": "Name of the animation (e.g., 'blood_flow', 'breathing', 'digestion')"
                    }
                },
                "required": ["animation_name"]
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
        """Send anatomy control command to frontend"""

        # Map function names to frontend actions
        action_map = {
            "navigate_to_organ": "navigate_to",
            "zoom_anatomy": "zoom",
            "highlight_structure": "highlight",
            "play_animation": "play_animation"
        }

        action = action_map.get(function_name)
        if not action:
            return

        # Prepare parameters based on function
        params = {}
        if function_name == "navigate_to_organ":
            params = {"organId": args.get("organ_id")}
        elif function_name == "zoom_anatomy":
            params = {"level": args.get("level")}
        elif function_name == "highlight_structure":
            params = {"structureId": args.get("structure_id")}
        elif function_name == "play_animation":
            params = {"animationName": args.get("animation_name")}

        # Send to frontend
        await websocket.send_json({
            "type": "anatomy_control",
            "action": action,
            "params": params
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
