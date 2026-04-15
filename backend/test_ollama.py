import asyncio
import httpx
import json
from datetime import datetime

OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL_NAME = "gemma4:e4b"

async def generate():
    current_month = datetime.now().strftime("%B")
    system_prompt = (
        "You are a travel expert AI. You provide accurate, trend-aware, and seasonal travel data. "
        "Always respond in STRICT JSON format. Do not include any conversational text, markdown outside the JSON, or explanations."
    )
    user_prompt = f"""
    Provide travel insights for Paris, France specifically for the month of {current_month}.
    
    Return a JSON object with exactly these keys:
    1. "ideal_duration_min": (int) Minimum days recommended.
    2. "ideal_duration_max": (int) Maximum days recommended.
    3. "average_daily_cost_inr": (int) Average daily budget per person in Indian Rupees.
    4. "luxury_daily_cost_inr": (int) Luxury daily budget per person in Indian Rupees.
    5. "best_season": (string) e.g., "Spring", "Winter (Current)".
    6. "attractions": A list of 10 objects (major landmarks & hidden gems), each with:
       - "name": (string)
       - "location_area": (string, e.g. "Shibuya", "Downtown", "Old Town")
       - "description": (string, 200-300 chars, vivid and engaging)
       - "category": (string: "SIGHTSEEING", "CULTURE", "NATURE", "DINING", etc.)
       - "typical_duration_hours": (float)
       - "is_popular": (boolean)
    
    Constraint: Ensure attractions are suitable for {current_month}.
    """
    
    async with httpx.AsyncClient(timeout=45.0) as client:
        payload = {
            "model": MODEL_NAME,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            "stream": False,
            "format": "json"
        }
        print("Sending to Ollama...")
        response = await client.post(OLLAMA_URL, json=payload)
        print("Response:", response.status_code)
        
        if response.status_code == 200:
            result = response.json()
            content = result.get("message", {}).get("content", "")
            print("Content:", content[:200])
            
            # Clean up JSON
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()
            
            try:
                parsed = json.loads(content)
                if isinstance(parsed, list) and len(parsed) > 0:
                    parsed = parsed[0]
                print("KEYS:", parsed.keys())
                print("Everything worked.")
            except Exception as e:
                print("JSON Error:", e)

if __name__ == "__main__":
    asyncio.run(generate())
