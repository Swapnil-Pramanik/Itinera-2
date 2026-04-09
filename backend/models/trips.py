from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date
from uuid import UUID

class TripCreate(BaseModel):
    destination_id: UUID
    title: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    departure_city: Optional[str] = None
    tags: Optional[List[str]] = []
    notes: Optional[str] = None
    budget_level: Optional[str] = "STANDARD"
    target_budget: Optional[int] = None

class TripUpdate(BaseModel):
    title: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    tags: Optional[List[str]] = None
    notes: Optional[str] = None
    status: Optional[str] = None
    budget_level: Optional[str] = None
    target_budget: Optional[int] = None

class TripResponse(BaseModel):
    id: UUID
    user_id: UUID
    destination_id: UUID
    status: str
    title: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    tags: Optional[List[str]] = []
    places_visited: int
    activities_done: int
    notes: Optional[str] = None
    budget_level: str
    target_budget: Optional[int] = None
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True
