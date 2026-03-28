from fastapi import APIRouter, Depends, HTTPException, Query, status
from core.security import get_current_user
from core.supabase import get_supabase
import httpx
from typing import Optional
import os

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
            supabase.table("search_history").insert({
                "user_id": user_id,
                "query": q,
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
def get_destination_by_name(
    name: str = Query(..., description="Destination name"),
    country: str = Query(..., description="Country name"),
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
            if not dest.get("image_url"):
                new_image_url = _fetch_unsplash_image(dest["name"])
                if new_image_url:
                    try:
                        supabase.table("destinations").update({"image_url": new_image_url}).eq("id", dest["id"]).execute()
                        dest["image_url"] = new_image_url
                    except Exception as e:
                        print(f"Failed to update image_url: {e}")
            return dest
    except Exception:
        pass

    # 2. Not cached — fetch from Wikipedia and Unsplash
    description = _fetch_wikipedia_summary(name)
    image_url = _fetch_unsplash_image(name)

    # 3. Insert into destinations table as cache
    new_dest = {
        "name": name,
        "country": country,
        "description": description or f"A destination in {country}.",
        "image_url": image_url,
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
# 5. Get destination by ID (from DB)
#    Path param route LAST to avoid conflicts
# ──────────────────────────────────────────────

@router.get("/{destination_id}")
def get_destination_by_id(
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
            if not dest.get("image_url"):
                new_image_url = _fetch_unsplash_image(dest["name"])
                if new_image_url:
                    try:
                        supabase.table("destinations").update({"image_url": new_image_url}).eq("id", dest["id"]).execute()
                        dest["image_url"] = new_image_url
                    except Exception:
                        pass
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
