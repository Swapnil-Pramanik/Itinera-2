from fastapi import APIRouter, Depends, HTTPException, status
from core.security import get_current_user
from core.supabase import get_supabase
from models import TripCreate

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
        "status": "PLANNED"
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
