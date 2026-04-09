import os
import json
import asyncio
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

async def test_itinerary():
    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("GEMINI_API_KEY not found")
        return

    client = genai.Client(api_key=gemini_key)
    
    days = 2
    city = "Tokyo"
    country = "Japan"
    start_date = "2024-05-01"
    
    system_prompt = (
        "You are an elite travel planner API. Respond solely with a highly realistic, logically ordered JSON array of objects. "
        f"CRITICAL CONSTRAINT: The JSON array MUST contain exactly {days} elements."
    )
    
    user_prompt = f"Create an exact {days}-day realistic itinerary for {city}, {country} starting on {start_date}."

    print(f"Testing with model: gemini-flash-latest")
    try:
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
                temperature=0.7,
            )
        )
        print("Success!")
        print(response.text)
    except Exception as e:
        print(f"Failed with gemini-flash-latest: {e}")

    print(f"\nTesting with model: gemini-1.5-flash")
    try:
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
                temperature=0.7,
            )
        )
        print("Success with gemini-1.5-flash!")
    except Exception as e:
        print(f"Failed with gemini-1.5-flash: {e}")

if __name__ == "__main__":
    asyncio.run(test_itinerary())
