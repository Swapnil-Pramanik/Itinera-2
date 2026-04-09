import os
import json
import asyncio
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

async def list_models():
    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("GEMINI_API_KEY not found")
        return

    client = genai.Client(api_key=gemini_key)
    
    print(f"Listing available models:")
    try:
        models = client.models.list()
        for m in models:
            if "generateContent" in m.supported_actions:
                print(f"- {m.name}")
    except Exception as e:
        print(f"Failed to list models: {e}")

if __name__ == "__main__":
    asyncio.run(list_models())
