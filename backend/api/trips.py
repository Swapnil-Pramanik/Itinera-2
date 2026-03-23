from fastapi import APIRouter, Depends, HTTPException, status
from core.security import get_current_user
from core.supabase import get_supabase

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
