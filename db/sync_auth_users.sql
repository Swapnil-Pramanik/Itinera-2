-- ============================================================================
-- MIGRATION: Sync auth.users → public.users on signup
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- ============================================================================

-- 1. Create the trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data ->> 'display_name', split_part(NEW.email, '@', 1))
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 3. Backfill: Sync any existing auth users that are missing from public.users
INSERT INTO public.users (id, email, display_name)
SELECT
    au.id,
    au.email,
    COALESCE(au.raw_user_meta_data ->> 'display_name', split_part(au.email, '@', 1))
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL;

-- ============================================================================
-- DONE — Every future signup will auto-create a public.users row.
-- Existing auth users have been backfilled.
-- ============================================================================
SELECT 'Auth → public.users sync trigger installed successfully!' AS status;
