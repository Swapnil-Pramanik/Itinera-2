from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Optional, List, Dict
from core.security import get_current_user
from core.supabase import get_supabase

router = APIRouter(prefix="/users", tags=["users"])

class UserProfileUpdate(BaseModel):
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None

class UserPreferencesUpdate(BaseModel):
    preferences: Dict[str, List[str]]

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
    if profile.display_name is not None:
        data["display_name"] = profile.display_name
    if profile.avatar_url is not None:
        data["avatar_url"] = profile.avatar_url
        
    try:
        response = supabase.table("users").upsert(data).execute()
        if hasattr(response, 'data') and len(response.data) > 0:
            return response.data[0]
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

@router.get("/me/preferences")
def get_user_preferences(user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    response = supabase.table("user_preferences").select("preference_key, preference_value").eq("user_id", user_id).execute()
    
    # Group preferences by key
    prefs = {}
    if hasattr(response, 'data'):
        for item in response.data:
            key = item['preference_key']
            val = item['preference_value']
            if key not in prefs:
                prefs[key] = []
            prefs[key].append(val)
            
    return prefs

@router.post("/me/preferences")
def update_user_preferences(prefs_data: Dict[str, List[str]], user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    try:
        # For simplicity, we'll replace the existing ones for the keys provided
        for key, values in prefs_data.items():
            # Delete existing preferences for this key
            supabase.table("user_preferences").delete().eq("user_id", user_id).eq("preference_key", key).execute()
            
            # Insert new ones
            if values:
                rows = [{"user_id": user_id, "preference_key": key, "preference_value": val} for val in values]
                supabase.table("user_preferences").insert(rows).execute()
                
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
