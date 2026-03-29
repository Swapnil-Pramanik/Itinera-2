import httpx
from cachetools import TTLCache
import time

# 2 hour cache (7200 seconds), maximum 1000 locations
weather_cache = TTLCache(maxsize=1000, ttl=7200)

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"

async def get_weather_forecast(lat: float, lon: float):
    # Round coordinates to 2 decimal places to increase cache hits for nearby areas (approx ~1km resolution)
    cache_key = f"{round(lat, 2)},{round(lon, 2)}"
    
    if cache_key in weather_cache:
        print(f"[Weather] Cache hit for {cache_key}")
        return weather_cache[cache_key]

    print(f"[Weather] Fetching Open-Meteo for {cache_key}")
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(
                OPEN_METEO_URL,
                params={
                    "latitude": lat,
                    "longitude": lon,
                    "current": "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m",
                    "hourly": "temperature_2m,weather_code,wind_speed_10m,wind_direction_10m",
                    "daily": "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max",
                    "timezone": "auto"
                }
            )
            
            if resp.status_code == 200:
                data = resp.json()
                weather_cache[cache_key] = data
                return data
            else:
                print(f"[Weather] API returned {resp.status_code}: {resp.text}")
                return None
    except Exception as e:
        print(f"[Weather] Error fetching weather: {e}")
        return None
