import asyncio
from core.supabase import get_supabase

def test_connection():
    try:
        supabase = get_supabase()
        response = supabase.table('destinations').select('id, name').limit(1).execute()
        print("Successfully connected to Supabase!")
        print(f"Test Query Result (Destinations): {response.data}")
    except Exception as e:
        print(f"Error connecting to Supabase: {e}")

if __name__ == "__main__":
    test_connection()
