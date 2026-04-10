from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from core.security import get_current_user
from core.supabase import get_supabase
from models.notifications import NotificationResponse

router = APIRouter(prefix="/notifications", tags=["notifications"])

@router.get("", response_model=List[NotificationResponse])
def get_notifications(user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    try:
        response = supabase.table("notifications")\
            .select("*")\
            .eq("user_id", user_id)\
            .order("created_at", desc=True)\
            .execute()
        
        return response.data
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

@router.post("/{notification_id}/read")
def mark_as_read(notification_id: str, user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    try:
        response = supabase.table("notifications")\
            .update({"is_read": True})\
            .eq("id", notification_id)\
            .eq("user_id", user_id)\
            .execute()
            
        if not response.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
        
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

@router.delete("/clear")
def clear_all_notifications(user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    try:
        # Delete all notifications for this user
        supabase.table("notifications").delete().eq("user_id", user_id).execute()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

@router.get("/unread-count")
def get_unread_count(user_payload: dict = Depends(get_current_user)):
    user_id = user_payload.get("sub")
    supabase = get_supabase()
    
    try:
        # Using select count doesn't work directly with the python client conveniently in all versions
        # so we select id and check length or use the count parameter if supported
        response = supabase.table("notifications")\
            .select("id", count="exact")\
            .eq("user_id", user_id)\
            .eq("is_read", False)\
            .execute()
        
        return {"count": response.count if hasattr(response, 'count') else len(response.data)}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
