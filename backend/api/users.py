from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Optional
from core.security import get_current_user
from core.supabase import get_supabase

router = APIRouter(prefix="/users", tags=["users"])

class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None

@router.get("/me")
def get_user_profile(user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    # Query the 'users' table linking to supabase auth id
    # assuming that `id` in `users` maps to the auth.uid
    response = supabase.table("users").select("*").eq("id", user_id).execute()
    
    if hasattr(response, 'data') and len(response.data) > 0:
        return response.data[0]
        
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User profile not found")

@router.post("/me")
def create_or_update_user_profile(profile: UserProfileUpdate, user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    email = user_payload.get("email")
    supabase = get_supabase()
    
    # Upsert the user profile
    data = {"id": user_id, "email": email}
    if profile.full_name is not None:
        data["full_name"] = profile.full_name
    if profile.avatar_url is not None:
        data["avatar_url"] = profile.avatar_url
        
    try:
        response = supabase.table("users").upsert(data).execute()
        if hasattr(response, 'data') and len(response.data) > 0:
            return response.data[0]
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
