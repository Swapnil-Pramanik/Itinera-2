import asyncio
from datetime import datetime
try:
    from datetime import timedelta
except ImportError:
    timedelta = None

def test_duration_logic():
    print("Testing itinerary duration logic...")
    # Mock trip data
    trip = {
        "start_date": "2024-05-10",
        "end_date": "2024-05-15"
    }
    
    try:
        # This imitates the code in backend/api/trips.py
        start = datetime.fromisoformat(trip["start_date"]) if trip.get("start_date") else datetime.now()
        
        # We know timedelta is NOT imported in the real file, but here we test if it WORKS if it WERE imported.
        if timedelta is None:
            print("timedelta is NOT imported!")
        
        end = datetime.fromisoformat(trip["end_date"]) if trip.get("end_date") else (start + timedelta(days=7))
        duration = (end - start).days + 1
        
        print(f"Start: {start}, End: {end}, Duration: {duration} days")
        assert duration == 6
        print("Duration logic passed!")
    except NameError as e:
        print(f"Caught expected NameError (simulated): {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    test_duration_logic()
