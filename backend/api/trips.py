from fastapi import APIRouter, Depends, HTTPException, status
from datetime import datetime, timedelta
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
        "departure_city": trip.departure_city,
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
from pydantic import BaseModel
from typing import Optional

class GenerateItineraryRequest(BaseModel):
    budget_level: Optional[str] = "STANDARD"
    current_activities: Optional[list] = None

@router.post("/{trip_id}/generate")
async def generate_itinerary(trip_id: str, req: GenerateItineraryRequest, user_payload: dict = Depends(get_current_user)):
    """Orchestrate AI itinerary generation and save to timeline_days & activities."""
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
        
        # Fetch User Preferences
        user_prefs = {}
        try:
            prefs_res = supabase.table("user_preferences").select("preference_key, preference_value").eq("user_id", user_id).execute()
            if hasattr(prefs_res, "data"):
                for row in prefs_res.data:
                    k, v = row["preference_key"], row["preference_value"]
                    user_prefs.setdefault(k, []).append(v)
        except Exception as e:
            print(f"[API] Error fetching prefs: {e}")

        # Fetch Weather Forecast
        weather_data = None
        if dest.get("latitude") and dest.get("longitude"):
            from core.weather import get_weather_forecast
            weather_data = await get_weather_forecast(dest["latitude"], dest["longitude"])
        
        # 2. Call AI
        from core.ai import generate_trip_itinerary
        itinerary = await generate_trip_itinerary(
            city=dest["name"],
            country=dest["country"],
            days=duration,
            start_date=trip["start_date"] or start.isoformat(),
            attractions=dest.get("attractions", []),
            user_preferences=user_prefs,
            weather_data=weather_data,
            budget_level=req.budget_level
        )
        
        if not itinerary:
            raise HTTPException(status_code=500, detail="AI failed to generate itinerary")
        
        # Enforce strict day count to prevent AI hallucination over-generation
        itinerary = itinerary[:duration]
        
        # 3. Save to timeline_days and activities
        # Clean up existing days for this trip (cascades to activities)
        supabase.table("timeline_days").delete().eq("trip_id", trip_id).execute()
        
        for day in itinerary:
            # Insert the day
            day_record = {
                "trip_id": trip_id,
                "day_number": day.get("day_number"),
                "theme": day.get("day_title"),
                "date": (start + timedelta(days=day.get("day_number", 1) - 1)).date().isoformat()
            }
            
            day_res = supabase.table("timeline_days").insert(day_record).execute()
            if not (hasattr(day_res, "data") and day_res.data):
                continue
                
            day_id = day_res.data[0]["id"]
            
            # Prepare activities
            activities_to_insert = []
            # Map AI categories to valid DB enum values
            CATEGORY_MAP = {
                "TRANSIT": "TRANSPORT",
                "BREAK": "RELAXATION",
            }
            for i, act in enumerate(day.get("activities", [])):
                # Map category
                raw_cat = act.get("type", "SIGHTSEEING")
                category = CATEGORY_MAP.get(raw_cat, raw_cat)
                
                # Convert AM/PM time to 24-hour for PostgreSQL TIME column
                raw_time = act.get("time")
                db_time = None
                if raw_time:
                    try:
                        from datetime import datetime as dt
                        # Try AM/PM format first
                        parsed = dt.strptime(raw_time.strip(), "%I:%M %p")
                        db_time = parsed.strftime("%H:%M:%S")
                    except ValueError:
                        try:
                            # Try 24-hour format
                            parsed = dt.strptime(raw_time.strip(), "%H:%M")
                            db_time = parsed.strftime("%H:%M:%S")
                        except ValueError:
                            db_time = None  # Skip invalid times
                
                activities_to_insert.append({
                    "timeline_day_id": day_id,
                    "title": act.get("title"),
                    "description": act.get("description"),
                    "start_time": db_time,
                    "duration_hours": float(act.get("duration_hours")) if act.get("duration_hours") is not None else None,
                    "category": category,
                    "transport_mode": act.get("transport_mode"),
                    "transport_duration_min": act.get("transport_duration_min"),
                    "sort_order": i
                })
            
            if activities_to_insert:
                supabase.table("activities").insert(activities_to_insert).execute()
            
        # 4. Update trip status
        supabase.table("trips").update({"status": "PLANNED"}).eq("id", trip_id).execute()
        
        return {"status": "success", "message": f"Successfully generated {len(itinerary)} days"}

    except Exception as e:
        print(f"[API] Itinerary generation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{trip_id}/generate_day/{day_number}")
async def regenerate_day(trip_id: str, day_number: int, req: GenerateItineraryRequest, user_payload: dict = Depends(get_current_user)):
    """Regenerate a specific day of the itinerary."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        # 1. Fetch trip and destination data
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
        
        start = datetime.fromisoformat(trip["start_date"]) if trip.get("start_date") else datetime.now()
        target_date = start + timedelta(days=day_number - 1)

        # Fetch User Preferences
        user_prefs = {}
        try:
            prefs_res = supabase.table("user_preferences").select("preference_key, preference_value").eq("user_id", user_id).execute()
            if hasattr(prefs_res, "data"):
                for row in prefs_res.data:
                    k, v = row["preference_key"], row["preference_value"]
                    user_prefs.setdefault(k, []).append(v)
        except Exception:
            pass

        # 2. Call AI specifically for 1 day
        from core.ai import generate_trip_itinerary, rebalance_day_itinerary
        
        if req.current_activities:
            # Rebalance existing day taking user cuts into account
            day_data = await rebalance_day_itinerary(
                city=dest["name"],
                country=dest["country"],
                date=target_date.isoformat(),
                attractions=dest.get("attractions", []),
                existing_activities=req.current_activities,
                user_preferences=user_prefs,
                budget_level=req.budget_level
            )
        else:
            # Fully regenerate the day from scratch
            itinerary = await generate_trip_itinerary(
                city=dest["name"],
                country=dest["country"],
                days=1,
                start_date=target_date.isoformat(),
                attractions=dest.get("attractions", []),
                user_preferences=user_prefs,
                weather_data=None, # Optimization: Skip weather fetch for faster single day rebuilds unless needed
                budget_level=req.budget_level
            )
            day_data = itinerary[0] if itinerary else None
        
        if not day_data:
            raise HTTPException(status_code=500, detail="AI failed to generate day")

        # 3. Save to database for THIS day only
        # First, find the timeline_day_id
        day_res = supabase.table("timeline_days").select("id").eq("trip_id", trip_id).eq("day_number", day_number).single().execute()
        
        if hasattr(day_res, "data") and day_res.data:
            day_id = day_res.data["id"]
            # Clear old activities
            supabase.table("activities").delete().eq("timeline_day_id", day_id).execute()
            # Update theme if AI gave a new one
            supabase.table("timeline_days").update({"theme": day_data.get("day_title", "Regenerated Day")}).eq("id", day_id).execute()
        else:
            # If day record somehow doesn't exist, create it
            day_record = {
                "trip_id": trip_id,
                "day_number": day_number,
                "theme": day_data.get("day_title", "Regenerated Day"),
                "date": target_date.date().isoformat()
            }
            new_day = supabase.table("timeline_days").insert(day_record).execute()
            day_id = new_day.data[0]["id"]
            
        # Compile new activities
        activities_to_insert = []
        CATEGORY_MAP = {"TRANSIT": "TRANSPORT", "BREAK": "RELAXATION"}
        
        for i, act in enumerate(day_data.get("activities", [])):
            raw_cat = act.get("type", "SIGHTSEEING")
            category = CATEGORY_MAP.get(raw_cat, raw_cat)
            
            raw_time = act.get("time")
            db_time = None
            if raw_time:
                try:
                    from datetime import datetime as dt
                    parsed = dt.strptime(raw_time.strip(), "%I:%M %p")
                    db_time = parsed.strftime("%H:%M:%S")
                except ValueError:
                    try:
                        parsed = dt.strptime(raw_time.strip(), "%H:%M")
                        db_time = parsed.strftime("%H:%M:%S")
                    except ValueError:
                        pass
            
            activities_to_insert.append({
                "timeline_day_id": day_id,
                "title": act.get("title"),
                "description": act.get("description"),
                "start_time": db_time,
                "duration_hours": float(act.get("duration_hours")) if act.get("duration_hours") is not None else None,
                "category": category,
                "transport_mode": act.get("transport_mode"),
                "transport_duration_min": act.get("transport_duration_min"),
                "sort_order": i
            })
            
        if activities_to_insert:
            supabase.table("activities").insert(activities_to_insert).execute()
            
        return {"status": "success", "message": "Day regenerated."}

    except Exception as e:
        print(f"[API] Day regeneration error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{trip_id}/itinerary")
def get_trip_itinerary(trip_id: str, user_payload: dict = Depends(get_current_user)):
    """Fetch the saved itinerary days for a trip, aggregated with activities."""
    user_id = user_payload.get("sub")
    supabase = get_supabase()

    try:
        # Verify ownership
        check = supabase.table("trips").select("id").eq("id", trip_id).eq("user_id", user_id).single().execute()
        if not (hasattr(check, "data") and check.data):
            raise HTTPException(status_code=404, detail="Trip not found")

        # Fetch days and join with activities
        # Note: We aggregate them into a format the Flutter app expects:
        # Each day having an 'activities' list.
        response = (
            supabase.table("timeline_days")
            .select("*, activities(*)")
            .eq("trip_id", trip_id)
            .order("day_number")
            .execute()
        )
        
        if not (hasattr(response, "data") and response.data):
            return []
            
        # Refactor for frontend compatibility (rename theme -> day_title for consistency if needed)
        result = []
        for day in response.data:
            activities_out = []
            for act in sorted(day.get("activities", []), key=lambda x: x.get("sort_order", 0)):
                # Convert 24-hour DB time back to display format
                raw_time = act.get("start_time")
                display_time = raw_time
                if raw_time:
                    try:
                        from datetime import datetime as dt
                        parsed = dt.strptime(raw_time, "%H:%M:%S")
                        display_time = parsed.strftime("%I:%M %p")
                    except (ValueError, TypeError):
                        display_time = raw_time
                
                activities_out.append({
                    "time": display_time,
                    "title": act.get("title"),
                    "description": act.get("description"),
                    "type": act.get("category"),
                    "duration_hours": act.get("duration_hours"),
                    "transport_mode": act.get("transport_mode"),
                    "transport_duration_min": act.get("transport_duration_min")
                })
            
            result.append({
                "day_number": day.get("day_number"),
                "day_title": day.get("theme"),
                "activities": activities_out
            })
        
        return result
    except Exception as e:
        print(f"[API] Get itinerary error: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

class TransportEstimateRequest(BaseModel):
    origin_title: str
    destination_title: str
    city: str
    country: str

@router.post("/{trip_id}/transport_estimate")
async def transport_estimate(trip_id: str, req: TransportEstimateRequest, user_payload: dict = Depends(get_current_user)):
    """Get Gemini-powered transport estimates between two activity locations."""
    try:
        from core.ai import estimate_transport_options
        result = await estimate_transport_options(
            origin=req.origin_title,
            destination=req.destination_title,
            city=req.city,
            country=req.country
        )
        if result:
            return result
        # Fallback if Gemini fails
        return {
            "currency": "INR",
            "walk": {"duration_min": 25, "price": 0, "price_inr": 0},
            "transit": {"duration_min": 15, "price": 30, "price_inr": 30},
            "taxi": {"duration_min": 8, "price": 200, "price_inr": 200},
            "recommended": "transit"
        }
    except Exception as e:
        print(f"[API] Transport estimate error: {e}")
        return {
            "currency": "INR",
            "walk": {"duration_min": 25, "price": 0, "price_inr": 0},
            "transit": {"duration_min": 15, "price": 30, "price_inr": 30},
            "taxi": {"duration_min": 8, "price": 200, "price_inr": 200},
            "recommended": "transit"
        }
