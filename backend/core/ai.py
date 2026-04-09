import httpx
import json
import asyncio
import os
from datetime import datetime
from typing import Optional, Dict, Any, List
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

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

def _parse_ai_json(text: str) -> Any:
    """Robustly parse JSON from AI response, handling markdown blocks."""
    if "```json" in text:
        text = text.split("```json")[1].split("```")[0].strip()
    elif "```" in text:
        text = text.split("```")[1].split("```")[0].strip()
    
    try:
        return json.loads(text)
    except json.JSONDecodeError as e:
        print(f"[AI] JSON Decode Error: {e}. Raw text: {text[:200]}...")
        raise

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type((Exception)), # Catch broad for Gemini SDK errors
    reraise=True
)
async def generate_trip_itinerary(
    city: str, 
    country: str, 
    days: int, 
    start_date: str, 
    attractions: list,
    user_preferences: dict = None,
    weather_data: dict = None,
    budget_level: str = "STANDARD"
) -> Optional[list]:
    from google import genai
    from google.genai import types

    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("[AI] GEMINI_API_KEY is not set.")
        return None

    client = genai.Client(api_key=gemini_key)
    
    # Process Contexts
    prefs_str = "None specified"
    if user_preferences:
        prefs_list = []
        for key, values in user_preferences.items():
            prefs_list.append(f"{key}: {', '.join(values)}")
        if prefs_list:
            prefs_str = "; ".join(prefs_list)

    weather_str = "Unknown"
    if weather_data and "current" in weather_data:
        temp = weather_data["current"].get("temperature_2m", "--")
        weather_str = f"{temp}°C based on recent forecasts"
        
    attr_str = ", ".join([a['name'] for a in attractions[:7]])
    
    system_prompt = (
        "You are an elite travel planner API. Respond solely with a highly realistic, logically ordered JSON array of objects. "
        f"CRITICAL CONSTRAINT: The JSON array MUST contain exactly {days} elements. If you generate more than {days} elements, the system will crash. "
        "Each object represents one day of the itinerary."
    )
    
    user_prompt = f"""
    Create an exact {days}-day realistic human-paced itinerary for {city}, {country} starting on {start_date}.
    
    CRITICAL CONSTRAINTS:
    - EXACTLY {days} DAYS: Your response MUST contain exactly {days} objects in the array. No more, no less. Label them day_number 1 to {days}.
    - ARRIVAL & DEPARTURE: You MUST include an 'Arrival at {city}' activity as the first activity on Day 1, and a 'Departure from {city}' activity as the last activity on Day {days}.
    
    CONTEXT:
    - User Preferences: {prefs_str}. (Focus the theme and activities around these if provided).
    - Weather Forecast: {weather_str}. (If extremely hot/cold/rainy, favor appropriate indoor/outdoor distribution).
    - Budget Level: {budget_level}. ("STANDARD" = normal/mid-range, "COMFORT" = upper mid-range/taxis, "LUXURY" = fine dining/private transport).
    - Key Anchors: Integrate some of these if relevant: {attr_str}.
    
    JSON REQUIREMENTS:
    Return an Array of EXACTLY {days} objects. Do NOT wrap it in any other object, just the array using `[]`.
    Format per Day Object:
    {{
      "day_number": int,
      "day_title": "string",
      "activities": [
        // CONTIGUOUS TIMELINE REQUIRED: Every minute between Day Start and Day End must be accounted for!
        {{
          "time": "HH:MM AM/PM",
          "title": "string",
          "description": "string",
          "type": "SIGHTSEEING" | "DINING" | "TRANSPORT" | "RELAXATION",
          "duration_hours": float,
          "transport_duration_min": int
        }}
      ]
    }}
    
    Ensure logical time flow: Morning -> Afternoon -> Evening. The next activity's `time` MUST closely match the current activity's `time` + `duration_hours`. Provide `TRANSPORT` type activities between venues.
    """

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
        
        parsed = _parse_ai_json(response.text)
        
        if isinstance(parsed, dict) and "itinerary" in parsed:
            return parsed["itinerary"]
        if isinstance(parsed, dict) and "days" in parsed:
            return parsed["days"]
        return parsed if isinstance(parsed, list) else None

    except Exception as e:
        print(f"[AI] Gemini Itinerary Generation error (attempting retry if applicable): {type(e).__name__}: {e}")
        raise e

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type((Exception)),
    reraise=True
)
async def rebalance_day_itinerary(
    city: str, 
    country: str, 
    date: str, 
    attractions: list,
    existing_activities: list,
    user_preferences: dict = None,
    budget_level: str = "STANDARD"
) -> Optional[dict]:
    from google import genai
    from google.genai import types

    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("[AI] GEMINI_API_KEY is not set.")
        return None

    client = genai.Client(api_key=gemini_key)
    
    prefs_str = "None specified"
    if user_preferences:
        prefs_list = []
        for key, values in user_preferences.items():
            prefs_list.append(f"{key}: {', '.join(values)}")
        if prefs_list:
            prefs_str = "; ".join(prefs_list)

    attr_str = ", ".join([a['name'] for a in attractions[:7]])
    
    existing_act_str = json.dumps(existing_activities, indent=2)

    system_prompt = (
        "You are an elite travel planner API. Respond solely with a highly realistic JSON object representing one day. "
        "Do not over-generate or under-generate the required format."
    )
    
    user_prompt = f"""
    The user has modified their itinerary for {city}, {country} on {date}, and there is now extra free time.
    Your goal is to REGENERATE this single day's itinerary by filling the time gaps.
    
    CRITICAL CONSTRAINTS:
    1. KEEP EXISTING ACTIVITIES: Keep existing activities mostly unchanged UNLESS they overlap due to over-scheduling.
    2. OVER-SCHEDULES: If the user increased an activity's duration and the schedule now overflows (e.g., past bedtime), you MUST explicitly drop less-important activities or shorten them to re-balance the chronological timeline properly.
    3. DO NOT DELETE ANCHORS: You absolutely must NOT delete "Arrival" and "Departure" activities. Reschedule them if absolutely mandatory, but they must exist.
    4. FILL THE GAPS: Inject new reasonable activities into any gaps created by shortened activities.
    
    Context:
    - User Preferences: {prefs_str}
    - Budget Level: {budget_level}
    
    Original Activities for this day (reflecting the user's modifications):
    {existing_act_str}
    
    JSON REQUIREMENTS:
    Return ONE JSON object. Format:
    {{
      "day_number": 1,
      "day_title": "string",
      "activities": [
        // CONTIGUOUS TIMELINE REQUIRED: Every minute between Day Start and Day End must be accounted for!
        {{
          "time": "HH:MM AM/PM",
          "title": "string",
          "description": "string",
          "type": "SIGHTSEEING" | "DINING" | "TRANSPORT" | "RELAXATION",
          "duration_hours": float,
          "transport_duration_min": int
        }}
      ]
    }}
    
    Ensure logical time flow: Morning -> Afternoon -> Evening. The next activity's `time` MUST closely match the current activity's `time` + `duration_hours`. Provide `TRANSPORT` type activities between venues.
    """

    try:
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
                temperature=0.4,
            )
        )
        
        return _parse_ai_json(response.text)

    except Exception as e:
        print(f"[AI] Gemini Day Rebalance error (attempting retry): {type(e).__name__}: {e}")
        raise e

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type((Exception)),
    reraise=True
)
async def estimate_transport_options(
    origin: str,
    destination: str,
    city: str,
    country: str,
) -> Optional[Dict[str, Any]]:
    """Use Gemini to estimate realistic transport options between two locations."""
    from google import genai
    from google.genai import types

    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("[AI] GEMINI_API_KEY is not set.")
        return None

    client = genai.Client(api_key=gemini_key)

    system_prompt = (
        "You are a transport estimation API for travellers. "
        "Respond solely with valid JSON. Do not add any markdown or text outside JSON."
    )

    user_prompt = f"""
    Estimate realistic transport options between two locations in {city}, {country}.

    Origin: {origin}
    Destination: {destination}

    Return a JSON object with the local currency for {country} and three transport modes:
    {{
      "currency": "string (e.g. EUR, JPY, USD) - Do not output INR if the country is not India",
      "walk": {{
        "duration_min": int,
        "price": 0,
        "price_inr": 0
      }},
      "transit": {{
        "duration_min": int,
        "price": int (in local currency),
        "price_inr": int (approximate conversion to Indian Rupees)
      }},
      "taxi": {{
        "duration_min": int,
        "price": int (in local currency),
        "price_inr": int (approximate conversion to Indian Rupees)
      }},
      "recommended": "walk" | "transit" | "taxi"
    }}

    Use realistic estimates based on typical distances in {city}. Prices must be in the local currency of {country}. Also provide the approximate equivalent value in INR (Indian Rupee) for convenience.
    """

    try:
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
                temperature=0.3,
            )
        )

        return _parse_ai_json(response.text)

    except Exception as e:
        print(f"[AI] Gemini Transport Estimate error (attempting retry): {type(e).__name__}: {e}")
        raise e
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type((Exception)),
    reraise=True
)
async def generate_budget_insights(
    city: str,
    country: str,
    departure_city: str,
    duration_days: int,
    activities: list,
    budget_level: str = "STANDARD",
    target_budget: Optional[int] = None,
) -> Optional[Dict[str, Any]]:
    """Use Gemini to generate a detailed budget breakdown for a trip."""
    from google import genai
    from google.genai import types

    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("[AI] GEMINI_API_KEY is not set.")
        return None

    client = genai.Client(api_key=gemini_key)

    activities_str = "\n".join([f"- {a.get('title')} ({a.get('category')})" for a in activities[:15]])

    system_prompt = (
        "You are a travel finance expert API. "
        "Respond solely with valid JSON. Do not add any markdown or text outside JSON."
    )

    budget_context = f"Budget Level: {budget_level}"
    if target_budget:
        budget_context += f", Target Total Budget: ₹{target_budget} (INR)"

    user_prompt = f"""
    Provide a detailed realistic budget estimation for a {duration_days}-day trip to {city}, {country} for one person.
    Departure City: {departure_city}
    {budget_context}

    Planned Activities:
    {activities_str}

    Return a JSON object with exactly these keys:
    {{
      "currency": "INR",
      "flight_estimate": {{
          "round_trip_min": int,
          "round_trip_max": int,
          "description": "string (e.g. 'Non-stop flights via Air India/JAL')"
      }},
      "hotel_tiers": {{
          "three_star": {{ "per_night": int, "total": int }},
          "four_star": {{ "per_night": int, "total": int }},
          "five_star": {{ "per_night": int, "total": int }}
      }},
      "activity_breakdown": [
          // List up to 5 major spending activities from the provided list
          {{ "activity_title": "string", "estimated_cost": int, "description": "string" }}
      ],
      "daily_expenses": {{
          "food_per_day": int,
          "local_transport_per_day": int,
          "total_daily_other": int
      }},
      "total_estimated_range": {{
          "min_total": int,
          "max_total": int
      }}
    }}

    CONSTRAINTS:
    1. Use realistic current market rates in Indian Rupees (INR).
    2. The total_estimated_range MUST be realistic based on the {budget_level} tier:
       - STANDARD: Focus on 3-star/4-star mix, affordable dining, and public transit.
       - COMFORT: Focus on solid 4-star hotels, taxis/Uber, and good restaurants.
       - LUXURY: Focus on 5-star hotels, private transfers, and fine dining.
    3. If Target Total Budget (₹{target_budget if target_budget else 'N/A'}) is provided, ensure your min_total and max_total estimates are realistically centered around this target, adjusting hotel tiers and daily spending accordingly.
    """

    try:
        response = client.models.generate_content(
            model='gemini-2.0-flash', 
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
                temperature=0.3,
            )
        )

        return _parse_ai_json(response.text)

    except Exception as e:
        print(f"[AI] Gemini Budget Estimate error (attempting retry): {type(e).__name__}: {e}")
        raise e

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type((Exception)),
    reraise=True
)
async def generate_trip_checklist(
    city: str,
    country: str,
    duration_days: int,
    start_date: str,
    itinerary: list,
    departure_city: str = "New Delhi"
) -> Optional[list]:
    """
    Generate a context-aware pre-trip checklist using Gemini.
    Considers India-specific context (Domestic vs International), weather, and activities.
    """
    from google import genai
    from google.genai import types

    gemini_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_key:
        print("[AI] GEMINI_API_KEY is not set.")
        return None

    client = genai.Client(api_key=gemini_key)

    is_international = country.lower() != "india"
    
    # Extract activity keywords to nudge packing list
    activities_summary = []
    for day in itinerary[:5]: # Use first 5 days for context
        for act in day.get('activities', []):
            activities_summary.append(act.get('title', ''))
    activities_str = ", ".join(activities_summary[:10])

    system_prompt = (
        "You are an expert travel assistant specializing in Indian travellers. "
        "Respond strictly with a JSON array of checklist items. "
        "Each item must have 'category' (Enum: TRAVEL, STAY, ESSENTIALS, DOCUMENTS, HEALTH) and 'label'."
    )

    user_prompt = f"""
    Create a detailed, context-aware pre-trip checklist for an Indian traveller going to {city}, {country} for {duration_days} days starting {start_date}.
    
    DEPARTURE CITY: {departure_city}
    NATURE: {'INTERNATIONAL' if is_international else 'DOMESTIC'}
    PLANNED ACTIVITIES: {activities_str}

    CRITICAL CONSTRAINTS:
    1. INDIA-FIRST CONTEXT: 
       - If INTERNATIONAL: Include Passport, Visa, International Roaming, Forex, Travel Insurance, Universal Power Adapter.
       - If DOMESTIC: Focus on Aadhar/ID, UPI setup, local transport apps.
    2. WEATHER & GEOGRAPHY: Based on {city} in {start_date}, suggest clothing (e.g. woollens if cold, umbrella if rainy, sunscreen if beach).
    3. ACTIVITY-BASED: If activities involve hiking, include boots. If swimming, include swimwear. If temples, include appropriate clothing.
    4. NO CHAT: Just the JSON array.

    Return Format:
    [
      {{ "category": "DOCUMENTS", "label": "string" }},
      {{ "category": "TRAVEL", "label": "string" }},
      ...
    ]
    """

    try:
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
                temperature=0.5,
            )
        )
        
        parsed = _parse_ai_json(response.text)
        return parsed if isinstance(parsed, list) else None

    except Exception as e:
        print(f"[AI] Checklist generation error (attempting retry): {type(e).__name__}: {e}")
        raise e
