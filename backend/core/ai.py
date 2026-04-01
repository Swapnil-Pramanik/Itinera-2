import httpx
import json
import asyncio
from datetime import datetime
from typing import Optional, Dict, Any

OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL_NAME = "gemma3:4b"

async def generate_destination_insights(name: str, country: str) -> Optional[Dict[str, Any]]:
    """
    Generate seasonal travel insights using local Ollama (Gemma:4b).
    Returns structured data for duration, costs, and top attractions.
    """
    current_month = datetime.now().strftime("%B")
    
    system_prompt = (
        "You are a travel expert AI. You provide accurate, trend-aware, and seasonal travel data. "
        "Always respond in STRICT JSON format. Do not include any conversational text, markdown outside the JSON, or explanations."
    )
    
    user_prompt = f"""
    Provide travel insights for {name}, {country} specifically for the month of {current_month}.
    
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

    try:
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
            
            response = await client.post(OLLAMA_URL, json=payload)
            
            if response.status_code == 200:
                result = response.json()
                content = result.get("message", {}).get("content", "")
                
                # Debug log
                print(f"[AI] Raw OLLAMA content: {content[:100]}...")

                # Cleanup potential markdown ticks if Ollama ignored the format constraint
                if "```json" in content:
                    content = content.split("```json")[1].split("```")[0].strip()
                elif "```" in content:
                    content = content.split("```")[1].split("```")[0].strip()
                
                parsed = json.loads(content)
                # Ensure it's a dict
                if isinstance(parsed, list) and len(parsed) > 0:
                    parsed = parsed[0]
                
                return parsed
            else:
                print(f"[AI] Ollama error: {response.status_code} - {response.text}")
                return None
                
    except Exception as e:
        print(f"[AI] Error generating insights: {e}")
        return None
async def generate_trip_itinerary(
    city: str, 
    country: str, 
    days: int, 
    start_date: str, 
    attractions: list
) -> Optional[list]:
    """
    Generate a day-by-day itinerary for a specific trip.
    Returns a list of day objects, each with a title and activities.
    """
    system_prompt = (
        "You are a travel planning AI. Create detailed, realistic, and high-quality itineraries. "
        "Always respond in STRICT JSON format. Do not include any conversational text."
    )
    
    # Format attractions for the prompt
    attr_str = "\n".join([f"- {a['name']} ({a.get('location_area', 'General')})" for a in attractions[:8]])
    
    user_prompt = f"""
    Create a {days}-day itinerary for {city}, {country} starting on {start_date}.
    
    Use these top attractions as anchors for the plan:
    {attr_str}
    
    Return a JSON ARRAY of objects, one for each day.
    Each object must have:
    1. "day_number": (int) 1, 2, 3...
    2. "day_title": (string) A catchy title for the day's theme.
    3. "activities": A list of 4-5 objects, each with:
       - "time": (string, e.g. "09:00 AM", "01:30 PM")
       - "title": (string)
       - "location": (string)
       - "description": (string, 100-150 chars)
       - "type": (string: "SIGHTSEEING", "DINING", "TRANSIT", "BREAK")
    
    Ensure logical flow (e.g., Morning -> Afternoon -> Evening) and include localized dining spots for lunch/dinner.
    """

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            payload = {
                "model": MODEL_NAME,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                "stream": False,
                "format": "json"
            }
            
            response = await client.post(OLLAMA_URL, json=payload)
            
            if response.status_code == 200:
                result = response.json()
                content = result.get("message", {}).get("content", "")
                
                # Cleanup potential markdown ticks
                if "```json" in content:
                    content = content.split("```json")[1].split("```")[0].strip()
                elif "```" in content:
                    content = content.split("```")[1].split("```")[0].strip()
                
                parsed = json.loads(content)
                # Should be a list
                if isinstance(parsed, dict) and "itinerary" in parsed:
                    return parsed["itinerary"]
                return parsed if isinstance(parsed, list) else None
            else:
                return None
    except Exception as e:
        print(f"[AI] Itinerary error: {e}")
        return None
