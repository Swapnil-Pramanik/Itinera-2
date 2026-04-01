from fastapi import APIRouter, Depends, HTTPException, status
from core.security import get_current_user
from core.supabase import get_supabase
from models.trips import TripCreate, TripUpdate, TripResponse

router = APIRouter(prefix="/trips", tags=["trips"])


@router.get("/me")
def get_my_trips(user_payload: dict = Depends(get_current_user)):
    """Fetch all trips for the authenticated user, joined with destination details."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        response = (
            supabase.table("trips")
            .select("*, destinations(name, country, tags, image_url)")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )

        if hasattr(response, "data"):
            return response.data  # Returns [] for new users with no trips

        return []
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e)
        )

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_trip(trip: TripCreate, user_payload: dict = Depends(get_current_user)):
    """Create a new trip for the user."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    # Optional logic: automatically fetch destination title if not provided
    title = trip.title
    if not title:
        try:
            dest_res = supabase.table("destinations").select("name").eq("id", str(trip.destination_id)).single().execute()
            if hasattr(dest_res, "data") and dest_res.data:
                title = f"Trip to {dest_res.data['name']}"
        except Exception:
            title = "My Trip"

    new_trip = {
        "user_id": user_id,
        "destination_id": str(trip.destination_id),
        "title": title,
        "start_date": trip.start_date.isoformat() if trip.start_date else None,
        "end_date": trip.end_date.isoformat() if trip.end_date else None,
        "tags": trip.tags,
        "notes": trip.notes,
        "status": "DRAFT"
    }

    try:
        response = supabase.table("trips").insert(new_trip).execute()
        if hasattr(response, "data") and response.data:
            return response.data[0]
        raise HTTPException(status_code=500, detail="Failed to create trip")
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e)
        )

@router.get("/{trip_id}")
def get_trip_by_id(trip_id: str, user_payload: dict = Depends(get_current_user)):
    """Fetch a specific trip by its UUID."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        response = (
            supabase.table("trips")
            .select("*, destinations(name, country, latitude, longitude, image_url)")
            .eq("id", trip_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if hasattr(response, "data") and response.data:
            return response.data
    except Exception:
        pass
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

@router.put("/{trip_id}", response_model=TripResponse)
def update_trip(trip_id: str, trip: TripUpdate, user_payload: dict = Depends(get_current_user)):
    """Update an existing trip."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    # 1. Verify existence and ownership
    try:
        check = supabase.table("trips").select("id").eq("id", trip_id).eq("user_id", user_id).single().execute()
        if not (hasattr(check, "data") and check.data):
            raise HTTPException(status_code=404, detail="Trip not found")
    except Exception:
        raise HTTPException(status_code=404, detail="Trip not found")

    # 2. Build update payload (only non-None values)
    update_data = {}
    if trip.title is not None: update_data["title"] = trip.title
    if trip.start_date is not None: update_data["start_date"] = trip.start_date.isoformat()
    if trip.end_date is not None: update_data["end_date"] = trip.end_date.isoformat()
    if trip.tags is not None: update_data["tags"] = trip.tags
    if trip.notes is not None: update_data["notes"] = trip.notes
    if trip.status is not None: update_data["status"] = trip.status

    if not update_data:
        # Fetch current if nothing to update
        res = supabase.table("trips").select("*").eq("id", trip_id).single().execute()
        return res.data

    try:
        response = supabase.table("trips").update(update_data).eq("id", trip_id).execute()
        if hasattr(response, "data") and response.data:
            return response.data[0]
        raise HTTPException(status_code=500, detail="Failed to update trip")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trip(trip_id: str, user_payload: dict = Depends(get_current_user)):
    """Delete a trip."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        # Check if exists and belongs to user
        trip_res = supabase.table("trips").select("id").eq("id", trip_id).eq("user_id", user_id).single().execute()
        if not (hasattr(trip_res, "data") and trip_res.data):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

        supabase.table("trips").delete().eq("id", trip_id).execute()
    except Exception as e:
        # If it's a 404 from single(), it will be caught here
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
@router.post("/{trip_id}/generate")
async def generate_itinerary(trip_id: str, user_payload: dict = Depends(get_current_user)):
    """Orchestrate AI itinerary generation and save to trip_days."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    # 1. Fetch trip and destination data
    try:
        trip_res = (
            supabase.table("trips")
            .select("*, destinations(*, attractions(*))")
            .eq("id", trip_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not (hasattr(trip_res, "data") and trip_res.data):
            raise HTTPException(status_code=404, detail="Trip not found")
        
        trip = trip_res.data
        dest = trip.get("destinations")
        if not dest:
            raise HTTPException(status_code=400, detail="Destination data missing")
        
        # Calculate duration
        start = datetime.fromisoformat(trip["start_date"]) if trip.get("start_date") else datetime.now()
        end = datetime.fromisoformat(trip["end_date"]) if trip.get("end_date") else (start + timedelta(days=7))
        duration = (end - start).days + 1
        
        # 2. Call AI
        from core.ai import generate_trip_itinerary
        itinerary = await generate_trip_itinerary(
            city=dest["name"],
            country=dest["country"],
            days=duration,
            start_date=trip["start_date"] or start.isoformat(),
            attractions=dest.get("attractions", [])
        )
        
        if not itinerary:
            raise HTTPException(status_code=500, detail="AI failed to generate itinerary")
        
        # 3. Save to trip_days
        # Clean up existing days for this trip
        supabase.table("trip_days").delete().eq("trip_id", trip_id).execute()
        
        days_to_insert = []
        for day in itinerary:
            days_to_insert.append({
                "trip_id": trip_id,
                "day_number": day.get("day_number"),
                "title": day.get("day_title"),
                "activities": day.get("activities", [])
            })
        
        if days_to_insert:
            supabase.table("trip_days").insert(days_to_insert).execute()
            
        # 4. Update trip status
        supabase.table("trips").update({"status": "PLANNED"}).eq("id", trip_id).execute()
        
        return {"status": "success", "days_count": len(days_to_insert)}

    except Exception as e:
        print(f"[API] Itinerary generation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{trip_id}/itinerary")
def get_trip_itinerary(trip_id: str, user_payload: dict = Depends(get_current_user)):
    """Fetch the saved itinerary days for a trip."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        # Verify ownership
        check = supabase.table("trips").select("id").eq("id", trip_id).eq("user_id", user_id).single().execute()
        if not (hasattr(check, "data") and check.data):
            raise HTTPException(status_code=404, detail="Trip not found")

        response = (
            supabase.table("trip_days")
            .select("*")
            .eq("trip_id", trip_id)
            .order("day_number")
            .execute()
        )
        
        if hasattr(response, "data"):
            return response.data
        return []
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
