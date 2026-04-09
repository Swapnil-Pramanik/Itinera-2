import os
import asyncio
from dotenv import load_dotenv
from core.ai import generate_trip_itinerary

load_dotenv()

async def verify_fix():
    print("Verifying AI Itinerary Generation Fix...")
    
    city = "London"
    country = "UK"
    days = 3
    start_date = "2024-06-01"
    attractions = [{"name": "Big Ben"}, {"name": "London Eye"}]
    
    try:
        # We manually use the model that has quota but is flaky
        # The tenacity decorator in core.ai should handle the 503
        itinerary = await generate_trip_itinerary(
            city=city,
            country=country,
            days=days,
            start_date=start_date,
            attractions=attractions
        )
        
        if itinerary and len(itinerary) == days:
            print(f"✅ Success! Generated {len(itinerary)} days.")
            for day in itinerary:
                print(f"  - Day {day.get('day_number')}: {day.get('day_title')}")
        else:
            print(f"❌ Failure! Result: {itinerary}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(verify_fix())
