from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime

class NotificationResponse(BaseModel):
    id: UUID
    user_id: UUID
    type: str
    title: str
    message: str
    action_label: Optional[str] = None
    action_route: Optional[str] = None
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True
