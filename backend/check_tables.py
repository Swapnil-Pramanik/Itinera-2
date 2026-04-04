from core.supabase import get_supabase

def check_tables():
    supabase = get_supabase()
    tables = ['trips', 'timeline_days', 'activities', 'trip_days']
    for table in tables:
        try:
            supabase.table(table).select('id').limit(1).execute()
            print(f"Table '{table}' exists.")
        except Exception:
            print(f"Table '{table}' does NOT exist.")

if __name__ == "__main__":
    check_tables()
