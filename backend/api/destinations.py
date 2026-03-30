from fastapi import APIRouter, Depends, HTTPException, Query, status
from core.security import get_current_user
from core.supabase import get_supabase
import httpx
from typing import Optional
import os
from core.weather import get_weather_forecast
from datetime import datetime, timedelta

router = APIRouter(prefix="/destinations", tags=["destinations"])

NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"
WIKIPEDIA_API_URL = "https://en.wikipedia.org/api/rest_v1/page/summary"
UNSPLASH_ACCESS_KEY = os.getenv("UNSPLASH_ACCESS_KEY")


# ──────────────────────────────────────────────
# 1. Search destinations (Nominatim + cache)
# ──────────────────────────────────────────────

@router.get("/search")
def search_destinations(
    q: str = Query(..., min_length=2, description="Search query"),
    user_payload: dict = Depends(get_current_user),
):
    """Search for destinations via Nominatim. Caches results in search_history."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    # 1. Check DB destinations first for matching cached results
    try:
        db_results = (
            supabase.table("destinations")
            .select("id, name, country, description, rating, review_count, best_season, image_url, tags, latitude, longitude")
            .ilike("name", f"%{q}%")
            .limit(5)
            .execute()
        )
        cached = db_results.data if hasattr(db_results, "data") else []
    except Exception:
        cached = []

    # 2. Also query Nominatim for broader results
    nominatim_results = []
    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(
                NOMINATIM_URL,
                params={
                    "q": q,
                    "format": "json",
                    "addressdetails": 1,
                    "limit": 10,
                    "accept-language": "en",
                },
                headers={"User-Agent": "Itinera-Travel-App/1.0 (swapnil@itinera.dev)"},
            )
            print(f"[Search] Nominatim status={resp.status_code} for q='{q}', results={len(resp.json()) if resp.status_code == 200 else 'N/A'}")
            if resp.status_code == 200:
                raw = resp.json()
                for item in raw:
                    addr = item.get("address", {})
                    # Extract the most relevant place name
                    name = (
                        addr.get("city")
                        or addr.get("town")
                        or addr.get("village")
                        or addr.get("municipality")
                        or addr.get("county")
                        or addr.get("state")
                        or item.get("name", "")
                    )
                    country = addr.get("country", "")
                    if name and country:
                        nominatim_results.append({
                            "name": name,
                            "country": country,
                            "lat": float(item.get("lat", 0)),
                            "lon": float(item.get("lon", 0)),
                            "display_name": item.get("display_name", ""),
                            "source": "nominatim",
                        })
    except Exception as e:
        print(f"[Search] Nominatim error: {e}")


    # 3. Save to search_history for the user
    if user_id and q:
        try:
            # If we have cached results, link the first one as the destination_id
            best_dest_id = cached[0].get("id") if cached else None
            
            supabase.table("search_history").insert({
                "user_id": user_id,
                "query": q,
                "destination_id": best_dest_id
            }).execute()
        except Exception:
            pass  # Non-critical

    # 4. Deduplicate: cached DB entries first, then Nominatim extras
    seen = set()
    results = []
    for item in cached:
        key = (item.get("name", "").lower(), item.get("country", "").lower())
        if key not in seen:
            seen.add(key)
            item["source"] = "cached"
            results.append(item)

    for item in nominatim_results:
        key = (item["name"].lower(), item["country"].lower())
        if key not in seen:
            seen.add(key)
            results.append(item)

    return results[:15]


# ──────────────────────────────────────────────
# 2. Recent searches (for search UI)
#    MUST be before /{destination_id} to avoid
#    FastAPI treating "recent" as a UUID
# ──────────────────────────────────────────────

@router.get("/search/recent")
def get_recent_searches(user_payload: dict = Depends(get_current_user)):
    """Fetch user's recent search queries."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        response = (
            supabase.table("search_history")
            .select("query, searched_at")
            .eq("user_id", user_id)
            .order("searched_at", desc=True)
            .limit(10)
            .execute()
        )
        if hasattr(response, "data"):
            # Deduplicate queries
            seen = set()
            unique = []
            for item in response.data:
                q = item.get("query", "").lower()
                if q and q not in seen:
                    seen.add(q)
                    unique.append(item)
            return unique[:5]
        return []
    except Exception:
        return []


# ──────────────────────────────────────────────
# 2.5 User's Destination History (My Atlas)
# ──────────────────────────────────────────────

@router.get("/history")
def get_user_destination_history(
    limit: int = Query(20, ge=1, le=100),
    user_payload: dict = Depends(get_current_user)
):
    """Fetch destinations that this specific user has searched for or viewed."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        # Join search_history with destinations
        # We select destinations where search_history.user_id = current_user
        response = (
            supabase.table("search_history")
            .select("searched_at, destinations!inner(*)")
            .eq("user_id", user_id)
            .order("searched_at", desc=True)
            .limit(limit * 2) # Fetch extra for deduplication
            .execute()
        )
        
        if hasattr(response, "data"):
            # Deduplicate by destination ID
            seen_ids = set()
            unique_destinations = []
            
            for item in response.data:
                dest = item.get("destinations")
                if dest and dest.get("id") not in seen_ids:
                    seen_ids.add(dest["id"])
                    # Carry over the most recent 'searched_at' for sorting if needed
                    dest["last_viewed_at"] = item.get("searched_at")
                    unique_destinations.append(dest)
                
                if len(unique_destinations) >= limit:
                    break
            
            return unique_destinations
            
        return []
    except Exception as e:
        print(f"[History] Error: {e}")
        return []


# ──────────────────────────────────────────────
# 3. Atlas articles (for home screen)
#    MUST be before /{destination_id}
# ──────────────────────────────────────────────

@router.get("/atlas/articles")
def get_atlas_articles(user_payload: dict = Depends(get_current_user)):
    """Fetch atlas articles for the home screen."""
    supabase = get_supabase()

    try:
        response = (
            supabase.table("atlas_articles")
            .select("*, destinations(id, name, country)")
            .order("created_at", desc=True)
            .limit(10)
            .execute()
        )
        if hasattr(response, "data"):
            return response.data
        return []
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e),
        )


# ──────────────────────────────────────────────
# 4. Get/create destination by name+country
#    (DB cache → Wikipedia fallback)
#    MUST be before /{destination_id}
# ──────────────────────────────────────────────

@router.get("/detail-by-name")
async def get_destination_by_name(
    name: str = Query(..., description="Destination name"),
    country: str = Query(..., description="Country name"),
    lat: Optional[float] = Query(None, description="Latitude"),
    lon: Optional[float] = Query(None, description="Longitude"),
    user_payload: dict = Depends(get_current_user),
):
    """
    Lookup destination in DB. If not found, fetch description from Wikipedia,
    create the destination record, and return it.
    """
    supabase = get_supabase()

    # 1. Check DB cache
    try:
        response = (
            supabase.table("destinations")
            .select("*, attractions(*)")
            .ilike("name", name)
            .ilike("country", country)
            .limit(1)
            .execute()
        )
        if hasattr(response, "data") and len(response.data) > 0:
            dest = response.data[0]
            needs_update = False
            
            # Update missing coordinates if provided or through lookup
            current_lat = dest.get("latitude")
            current_lon = dest.get("longitude")
            
            if current_lat is None or current_lon is None:
                if lat is not None and lon is not None:
                    dest["latitude"] = lat
                    dest["longitude"] = lon
                    needs_update = True
                else:
                    # Recovery: lookup coords via Nominatim
                    coords = await _fetch_nominatim_coords(name, country)
                    if coords:
                        dest["latitude"] = coords["lat"]
                        dest["longitude"] = coords["lon"]
                        needs_update = True
            
            # Fetch / Update Image
            if not dest.get("image_url"):
                new_image_url = _fetch_unsplash_image(dest["name"])
                if new_image_url:
                    dest["image_url"] = new_image_url
                    needs_update = True
                    
            # Fetch / Cache Weather
            final_lat = dest.get("latitude")
            final_lon = dest.get("longitude")
            if final_lat is not None and final_lon is not None:
                weather_data = await get_weather_forecast(lat=float(final_lat), lon=float(final_lon))
                if weather_data:
                    if dest.get("metadata") is None:
                        dest["metadata"] = {}
                    dest["metadata"]["weather"] = weather_data
                    needs_update = True
            
            if needs_update:
                try:
                    update_payload = {}
                    if "latitude" in dest: update_payload["latitude"] = dest["latitude"]
                    if "longitude" in dest: update_payload["longitude"] = dest["longitude"]
                    if "image_url" in dest: update_payload["image_url"] = dest["image_url"]
                    if "metadata" in dest: update_payload["metadata"] = dest["metadata"]
                    supabase.table("destinations").update(update_payload).eq("id", dest["id"]).execute()
                except Exception as e:
                    print(f"Failed to update cache: {e}")
            
            # Record view in history
            _record_search_history(user_id=user_payload.get("sub"), dest_id=dest["id"], query=name)
                    
            return dest
    except Exception:
        pass

    # 2. Not cached — fetch from Wikipedia and Unsplash
    description = _fetch_wikipedia_summary(name)
    image_url = _fetch_unsplash_image(name)
    
    # Also find coordinates for new destination
    final_lat, final_lon = lat, lon
    if final_lat is None or final_lon is None:
        coords = await _fetch_nominatim_coords(name, country)
        if coords:
            final_lat, final_lon = coords["lat"], coords["lon"]

    # 3. Fetch Weather for new destination
    metadata = {}
    if final_lat is not None and final_lon is not None:
        weather_data = await get_weather_forecast(lat=float(final_lat), lon=float(final_lon))
        if weather_data:
            metadata["weather"] = weather_data

    # 4. Insert into destinations table as cache
    new_dest = {
        "name": name,
        "country": country,
        "description": description or f"A destination in {country}.",
        "image_url": image_url,
        "latitude": final_lat,
        "longitude": final_lon,
        "metadata": metadata,
        "tags": [],
    }

    try:
        insert_resp = (
            supabase.table("destinations")
            .insert(new_dest)
            .execute()
        )
        if hasattr(insert_resp, "data") and len(insert_resp.data) > 0:
            dest = insert_resp.data[0]
            dest["attractions"] = []
            # Record view in history
            _record_search_history(user_id=user_payload.get("sub"), dest_id=dest["id"], query=name)
            return dest
    except Exception as e:
        # Might conflict if race condition — try fetching again
        try:
            response = (
                supabase.table("destinations")
                .select("*, attractions(*)")
                .ilike("name", name)
                .ilike("country", country)
                .limit(1)
                .execute()
            )
            if hasattr(response, "data") and len(response.data) > 0:
                return response.data[0]
        except Exception:
            pass

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create destination: {str(e)}",
        )


# ──────────────────────────────────────────────
# 5. Get weather by destination ID
# ──────────────────────────────────────────────

@router.get("/{destination_id}/weather")
async def get_destination_weather(
    destination_id: str,
    user_payload: dict = Depends(get_current_user),
):
    """Fetch current and forecasted weather for a destination."""
    supabase = get_supabase()

    # 1. Get destination coordinates
    try:
        response = (
            supabase.table("destinations")
            .select("latitude, longitude")
            .eq("id", destination_id)
            .single()
            .execute()
        )
        if not (hasattr(response, "data") and response.data):
            raise ValueError("Destination has no data")
            
        data = response.data
        lat = data.get("latitude")
        lon = data.get("longitude")
        
        if lat is None or lon is None:
            raise HTTPException(status_code=400, detail="Destination lacks coordinates")
            
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=404, detail="Destination not found")

    # 2. Fetch weather using core service
    weather_data = await get_weather_forecast(lat=float(lat), lon=float(lon))
    
    if weather_data:
        return weather_data
    else:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE, 
            detail="Weather service unavailable"
        )


# ──────────────────────────────────────────────
# 6. Get destination by ID (from DB)
#    Path param route LAST to avoid conflicts
# ──────────────────────────────────────────────

@router.get("/{destination_id}")
async def get_destination_by_id(
    destination_id: str,
    user_payload: dict = Depends(get_current_user),
):
    """Fetch a cached destination by its UUID, including attractions."""
    supabase = get_supabase()

    try:
        response = (
            supabase.table("destinations")
            .select("*, attractions(*)")
            .eq("id", destination_id)
            .single()
            .execute()
        )
        if hasattr(response, "data") and response.data:
            dest = response.data
            needs_update = False
            
            # Recovery: Lookup coordinates if missing
            current_lat = dest.get("latitude")
            current_lon = dest.get("longitude")
            if current_lat is None or current_lon is None:
                coords = await _fetch_nominatim_coords(dest["name"], dest["country"])
                if coords:
                    dest["latitude"] = coords["lat"]
                    dest["longitude"] = coords["lon"]
                    needs_update = True
            
            if not dest.get("image_url"):
                new_image_url = _fetch_unsplash_image(dest["name"])
                if new_image_url:
                    dest["image_url"] = new_image_url
                    needs_update = True
                    
            final_lat = dest.get("latitude")
            final_lon = dest.get("longitude")
            if final_lat is not None and final_lon is not None:
                weather_data = await get_weather_forecast(lat=float(final_lat), lon=float(final_lon))
                if weather_data:
                    if dest.get("metadata") is None:
                        dest["metadata"] = {}
                    dest["metadata"]["weather"] = weather_data
                    needs_update = True
                    
            if needs_update:
                try:
                    update_payload = {}
                    if "latitude" in dest: update_payload["latitude"] = dest["latitude"]
                    if "longitude" in dest: update_payload["longitude"] = dest["longitude"]
                    if "image_url" in dest: update_payload["image_url"] = dest["image_url"]
                    if "metadata" in dest: update_payload["metadata"] = dest["metadata"]
                    supabase.table("destinations").update(update_payload).eq("id", dest["id"]).execute()
                except Exception:
                    pass
            
            # Record view in history
            _record_search_history(user_id=user_payload.get("sub"), dest_id=dest["id"], query=dest["name"])
                    
            return dest
    except Exception:
        pass

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Destination not found")


# ──────────────────────────────────────────────
# Helper: Wikipedia summary fetcher
# ──────────────────────────────────────────────

def _fetch_wikipedia_summary(topic: str) -> Optional[str]:
    """Fetch the summary/extract of a Wikipedia article."""
    try:
        with httpx.Client(timeout=8.0) as client:
            slug = topic.strip().replace(" ", "_")
            resp = client.get(
                f"{WIKIPEDIA_API_URL}/{slug}",
                headers={"User-Agent": "Itinera-Travel-App/1.0 (swapnil@itinera.dev)"},
            )
            if resp.status_code == 200:
                data = resp.json()
                return data.get("extract", "")
    except Exception:
        pass
    return None


def _fetch_unsplash_image(topic: str) -> Optional[str]:
    """Fetch a high-res landscape image URL from Unsplash based on the topic."""
    if not UNSPLASH_ACCESS_KEY:
        print("[_fetch_unsplash_image] No UNSPLASH_ACCESS_KEY provided.")
        return None

    try:
        with httpx.Client(timeout=8.0) as client:
            resp = client.get(
                "https://api.unsplash.com/search/photos",
                params={
                    "query": topic,
                    "per_page": 1,
                    "orientation": "landscape"
                },
                headers={
                    "Authorization": f"Client-ID {UNSPLASH_ACCESS_KEY}",
                    "Accept-Version": "v1"
                },
            )
            if resp.status_code == 200:
                data = resp.json()
                results = data.get("results", [])
                if results:
                    raw_url = results[0].get("urls", {}).get("raw")
                    if raw_url:
                        return f"{raw_url}&w=1080&q=80&fit=crop"
    except Exception as e:
        print(f"[_fetch_unsplash_image] error: {e}")
    return None

async def _fetch_nominatim_coords(name: str, country: str) -> Optional[dict]:
    """Fetch coordinates from Nominatim based on destination name and country."""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(
                NOMINATIM_URL,
                params={
                    "q": f"{name}, {country}",
                    "format": "json",
                    "limit": 1,
                    "accept-language": "en",
                },
                headers={"User-Agent": "Itinera-Travel-App/1.0 (swapnil@itinera.dev)"},
            )
            if resp.status_code == 200:
                data = resp.json()
                if data:
                    return {
                        "lat": float(data[0].get("lat")),
                        "lon": float(data[0].get("lon"))
                    }
    except Exception as e:
        print(f"[_fetch_nominatim_coords] error: {e}")
    return None

def _record_search_history(user_id: str, dest_id: str, query: Optional[str] = None):
    """Record a destination view/search in the user's history."""
    if not (user_id and dest_id):
        return

    supabase = get_supabase()
    try:
        # Check for recent same destination to avoid spamming
        five_mins_ago = (datetime.utcnow() - timedelta(minutes=5)).isoformat()
        
        existing = (
            supabase.table("search_history")
            .select("id")
            .eq("user_id", user_id)
            .eq("destination_id", dest_id)
            .gte("searched_at", five_mins_ago)
            .limit(1)
            .execute()
        )
        
        if hasattr(existing, "data") and len(existing.data) > 0:
            # Already recorded in last 5 mins, skip
            return
            
        supabase.table("search_history").insert({
            "user_id": user_id,
            "destination_id": dest_id,
            "query": query or "Viewed details"
        }).execute()
    except Exception as e:
        print(f"[_record_search_history] Error: {e}")
