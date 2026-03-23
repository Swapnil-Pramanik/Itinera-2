-- ============================================================================
-- ITINERA DATABASE SCHEMA
-- PostgreSQL 15+ compatible, idempotent initialization script
-- Generated: 2026-02-05
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUM TYPES
-- ============================================================================

DO $$ BEGIN
    CREATE TYPE auth_provider AS ENUM ('GOOGLE', 'APPLE', 'EMAIL');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE trip_status AS ENUM ('PLANNED', 'SCHEDULED', 'ACTIVE', 'COMPLETED', 'CANCELLED');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE transport_mode AS ENUM ('WALK', 'TRAIN', 'TAXI', 'BUS', 'SUBWAY', 'BIKE', 'CAR');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE activity_category AS ENUM (
        'SIGHTSEEING', 'DINING', 'SHOPPING', 'CULTURE', 'NATURE', 
        'ENTERTAINMENT', 'RELAXATION', 'ADVENTURE', 'TRANSPORT', 'ACCOMMODATION'
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE expense_category AS ENUM (
        'FLIGHT', 'TRAIN', 'TRANSPORT', 'HOTEL', 'ACCOMMODATION',
        'FOOD', 'DINING', 'ATTRACTION', 'SHOPPING', 'INSURANCE', 'OTHER'
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE checklist_category AS ENUM ('TRAVEL', 'STAY', 'ESSENTIALS', 'DOCUMENTS', 'HEALTH');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- USERS & AUTHENTICATION
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255), -- NULL for OAuth-only users
    display_name VARCHAR(100),
    avatar_url TEXT,
    explorer_level INTEGER DEFAULT 1 CHECK (explorer_level >= 1 AND explorer_level <= 100),
    total_trips_completed INTEGER DEFAULT 0,
    total_places_visited INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    preference_key VARCHAR(50) NOT NULL,
    preference_value VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, preference_key, preference_value)
);

CREATE TABLE IF NOT EXISTS linked_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider auth_provider NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),
    is_connected BOOLEAN DEFAULT TRUE,
    connected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, provider),
    UNIQUE(provider, provider_user_id)
);

-- ============================================================================
-- DESTINATIONS & ATTRACTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS destinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    description TEXT,
    rating DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0,
    best_season VARCHAR(50), -- e.g., 'Spring', 'Best in Spring'
    ideal_duration_min_days INTEGER,
    ideal_duration_max_days INTEGER,
    estimated_daily_cost_usd DECIMAL(10,2),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    timezone VARCHAR(50),
    currency_code VARCHAR(3),
    image_url TEXT,
    tags TEXT[], -- PostgreSQL array for flexible tagging
    metadata JSONB DEFAULT '{}', -- For extensible data
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, country)
);

CREATE TABLE IF NOT EXISTS attractions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    location_area VARCHAR(100), -- e.g., 'Asakusa', 'Shibuya'
    description TEXT,
    category VARCHAR(50), -- e.g., 'TEMPLE', 'PARK', 'LANDMARK'
    typical_duration_hours DECIMAL(3,1),
    admission_fee_usd DECIMAL(10,2),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    image_url TEXT,
    is_popular BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS atlas_articles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    destination_id UUID REFERENCES destinations(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    content TEXT, -- Full article content
    read_duration VARCHAR(20), -- e.g., '8 MIN READ'
    category VARCHAR(50), -- e.g., 'TRENDING', 'SEASONAL', 'HIDDEN GEMS'
    tags TEXT[],
    image_url TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TRIPS & TIMELINE
-- ============================================================================

CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE RESTRICT,
    status trip_status DEFAULT 'PLANNED',
    title VARCHAR(200), -- Custom trip name
    start_date DATE,
    end_date DATE,
    tags TEXT[], -- e.g., ['URBAN', 'FOOD', 'CULTURE']
    places_visited INTEGER DEFAULT 0, -- Updated on completion
    activities_done INTEGER DEFAULT 0, -- Updated on completion
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS timeline_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL CHECK (day_number >= 1),
    date DATE,
    theme VARCHAR(100), -- e.g., 'Asakusa & Ueno', 'Culture & Food'
    is_day_off BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(trip_id, day_number)
);

CREATE TABLE IF NOT EXISTS activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timeline_day_id UUID NOT NULL REFERENCES timeline_days(id) ON DELETE CASCADE,
    attraction_id UUID REFERENCES attractions(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_time TIME,
    end_time TIME,
    duration_hours DECIMAL(3,1),
    category activity_category,
    transport_mode transport_mode,
    transport_duration_min INTEGER,
    icon_name VARCHAR(50), -- Flutter icon name for UI
    icon_color VARCHAR(20), -- Hex color code
    is_completed BOOLEAN DEFAULT FALSE,
    is_skipped BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CHECKLIST
-- ============================================================================

CREATE TABLE IF NOT EXISTS checklist_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category checklist_category NOT NULL,
    label VARCHAR(200) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS checklist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    template_id UUID REFERENCES checklist_templates(id) ON DELETE SET NULL,
    category checklist_category NOT NULL,
    label VARCHAR(200) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- BUDGET & EXPENSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL UNIQUE REFERENCES trips(id) ON DELETE CASCADE,
    total_estimated_usd DECIMAL(10,2),
    total_actual_usd DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    is_within_budget BOOLEAN,
    user_budget_limit_usd DECIMAL(10,2), -- User's preferred limit
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS budget_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_id UUID NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    timeline_day_id UUID REFERENCES timeline_days(id) ON DELETE SET NULL,
    day_number INTEGER NOT NULL,
    subtitle VARCHAR(100), -- e.g., 'Arrival & Check-In'
    estimated_total_usd DECIMAL(10,2),
    actual_total_usd DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS expense_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_day_id UUID NOT NULL REFERENCES budget_days(id) ON DELETE CASCADE,
    activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
    category expense_category NOT NULL,
    label VARCHAR(200) NOT NULL,
    estimated_amount_usd DECIMAL(10,2),
    actual_amount_usd DECIMAL(10,2),
    is_free BOOLEAN DEFAULT FALSE,
    is_paid BOOLEAN DEFAULT FALSE,
    notes TEXT,
    icon_name VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS budget_tips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_id UUID REFERENCES budgets(id) ON DELETE CASCADE,
    destination_id UUID REFERENCES destinations(id) ON DELETE CASCADE,
    tip_number INTEGER,
    content TEXT NOT NULL,
    potential_savings_usd DECIMAL(10,2),
    is_ai_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CHECK (budget_id IS NOT NULL OR destination_id IS NOT NULL)
);

-- ============================================================================
-- SEARCH & DISCOVERY
-- ============================================================================

CREATE TABLE IF NOT EXISTS search_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID REFERENCES destinations(id) ON DELETE SET NULL,
    query VARCHAR(200),
    searched_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS suggested_destinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- NULL for global suggestions
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    reason VARCHAR(200), -- e.g., 'Based on your preferences'
    score DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_linked_accounts_user_id ON linked_accounts(user_id);

CREATE INDEX IF NOT EXISTS idx_destinations_country ON destinations(country);
CREATE INDEX IF NOT EXISTS idx_destinations_name ON destinations(name);
CREATE INDEX IF NOT EXISTS idx_attractions_destination_id ON attractions(destination_id);
CREATE INDEX IF NOT EXISTS idx_atlas_articles_destination_id ON atlas_articles(destination_id);

CREATE INDEX IF NOT EXISTS idx_trips_user_id ON trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trips_destination_id ON trips(destination_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_dates ON trips(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_timeline_days_trip_id ON timeline_days(trip_id);
CREATE INDEX IF NOT EXISTS idx_activities_timeline_day_id ON activities(timeline_day_id);

CREATE INDEX IF NOT EXISTS idx_checklist_items_trip_id ON checklist_items(trip_id);
CREATE INDEX IF NOT EXISTS idx_budgets_trip_id ON budgets(trip_id);
CREATE INDEX IF NOT EXISTS idx_budget_days_budget_id ON budget_days(budget_id);
CREATE INDEX IF NOT EXISTS idx_expense_items_budget_day_id ON expense_items(budget_day_id);

CREATE INDEX IF NOT EXISTS idx_search_history_user_id ON search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_search_history_searched_at ON search_history(searched_at DESC);

-- ============================================================================
-- TRIGGER FOR updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS update_%I_updated_at ON %I;
            CREATE TRIGGER update_%I_updated_at
                BEFORE UPDATE ON %I
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at_column();
        ', t, t, t, t);
    END LOOP;
END;
$$;

-- ============================================================================
-- SEED DATA: Default Checklist Templates
-- ============================================================================

INSERT INTO checklist_templates (category, label, sort_order) VALUES
    ('TRAVEL', 'Book flights', 1),
    ('TRAVEL', 'Get travel insurance', 2),
    ('TRAVEL', 'Purchase rail pass if needed', 3),
    ('TRAVEL', 'Download offline maps', 4),
    ('STAY', 'Book accommodation', 1),
    ('STAY', 'Confirm hotel reservations', 2),
    ('DOCUMENTS', 'Check passport validity', 1),
    ('DOCUMENTS', 'Apply for visa if needed', 2),
    ('ESSENTIALS', 'Pack luggage', 1),
    ('ESSENTIALS', 'Prepare travel adapters', 2),
    ('ESSENTIALS', 'Exchange currency', 3),
    ('HEALTH', 'Check vaccination requirements', 1),
    ('HEALTH', 'Pack medications', 2)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED DATA: Sample Destinations (from Flutter hardcoded data)
-- ============================================================================

INSERT INTO destinations (name, country, description, rating, review_count, best_season, 
    ideal_duration_min_days, ideal_duration_max_days, estimated_daily_cost_usd, tags) VALUES
    ('Tokyo', 'Japan', 
     'A neon-lit blend of old and new, where ancient temples stand in the shadow of skyscrapers. Tokyo offers a sensory overload of culture, cuisine, and cutting-edge technology.',
     4.9, 20000, 'Spring', 7, 10, 150, ARRAY['URBAN', 'FOOD', 'CULTURE']),
    ('Kyoto', 'Japan',
     'The cultural heart of Japan, where traditional tea houses and ancient temples transport you to another era. Famous for its autumn foliage and cherry blossoms.',
     4.8, 15000, 'Autumn', 5, 7, 120, ARRAY['CULTURE', 'NATURE', 'TEMPLES']),
    ('Paris', 'France',
     'The City of Light enchants with its iconic landmarks, world-class museums, and romantic atmosphere. A paradise for art lovers and gourmands alike.',
     4.7, 25000, 'Spring', 5, 7, 200, ARRAY['ROMANTIC', 'ART', 'FOOD']),
    ('Bali', 'Indonesia',
     'A tropical paradise where lush rice terraces meet pristine beaches. Bali offers spiritual retreats, vibrant nightlife, and authentic cultural experiences.',
     4.6, 18000, 'Summer', 7, 14, 80, ARRAY['BEACH', 'NATURE', 'RELAXATION'])
ON CONFLICT (name, country) DO NOTHING;

-- ============================================================================
-- SEED DATA: Sample Attractions (Tokyo)
-- ============================================================================

INSERT INTO attractions (destination_id, name, location_area, description, category, 
    typical_duration_hours, is_popular) 
SELECT d.id, a.name, a.location_area, a.description, a.category, a.hours, a.popular
FROM destinations d
CROSS JOIN (VALUES
    ('Senso-ji Temple', 'Asakusa', 'Tokyo''s oldest and most significant Buddhist temple', 'TEMPLE', 2.0, TRUE),
    ('Shibuya Crossing', 'Shibuya', 'The world''s busiest pedestrian crossing', 'LANDMARK', 0.5, TRUE),
    ('Meiji Shrine', 'Harajuku', 'Shinto shrine dedicated to Emperor Meiji', 'SHRINE', 1.5, TRUE),
    ('Nakamise Street', 'Asakusa', 'Traditional shopping street leading to Senso-ji', 'SHOPPING', 1.0, FALSE),
    ('Ueno Park', 'Ueno', 'Large public park with museums and zoo', 'PARK', 3.0, TRUE),
    ('Tokyo Metropolitan Building', 'Shinjuku', 'Free observation deck with city views', 'LANDMARK', 1.0, TRUE),
    ('TeamLab Borderless', 'Odaiba', 'Immersive digital art museum', 'MUSEUM', 2.5, TRUE),
    ('Tsukiji Outer Market', 'Ginza', 'Famous fish market with fresh seafood', 'MARKET', 2.0, TRUE),
    ('Akihabara', 'Akihabara', 'Electronics and anime culture district', 'DISTRICT', 3.0, FALSE)
) AS a(name, location_area, description, category, hours, popular)
WHERE d.name = 'Tokyo' AND d.country = 'Japan'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED DATA: Atlas Articles
-- ============================================================================

INSERT INTO atlas_articles (destination_id, title, description, read_duration, category, is_featured)
SELECT d.id, a.title, a.description, a.read_duration, a.category, a.featured
FROM destinations d
CROSS JOIN (VALUES
    ('Kyoto', 'Japan', 'Kyoto in Autumn', 'Experience the magical transformation of ancient temples surrounded by fiery maple leaves.', '8 MIN READ', 'SEASONAL', TRUE),
    ('Tokyo', 'Japan', 'Hidden Tokyo', 'Discover the secret spots locals love, from underground jazz bars to rooftop gardens.', '10 MIN READ', 'HIDDEN GEMS', FALSE)
) AS a(dest_name, dest_country, title, description, read_duration, category, featured)
WHERE d.name = a.dest_name AND d.country = a.dest_country
ON CONFLICT DO NOTHING;

INSERT INTO atlas_articles (title, description, read_duration, category, is_featured) VALUES
    ('Nordic Escape', 'Chase the Northern Lights through Norway, Sweden, and Finland''s winter wonderlands.', '12 MIN READ', 'TRENDING', TRUE),
    ('Taste of Tuscany', 'A culinary journey through rolling hills, ancient vineyards, and authentic Italian trattorias.', '9 MIN READ', 'FOOD', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE users IS 'User accounts with authentication and profile data';
COMMENT ON TABLE destinations IS 'Travel destinations with metadata and AI-ready fields';
COMMENT ON TABLE trips IS 'User trip plans with status tracking';
COMMENT ON TABLE timeline_days IS 'Day-by-day breakdown of trip itineraries';
COMMENT ON TABLE activities IS 'Individual activities within timeline days';
COMMENT ON TABLE budgets IS 'Trip budget estimates and tracking';
COMMENT ON TABLE expense_items IS 'Individual expense line items';

COMMENT ON COLUMN destinations.metadata IS 'JSONB field for AI-generated insights and extensible data';
COMMENT ON COLUMN activities.metadata IS 'JSONB field for AI recommendations and custom data';
COMMENT ON COLUMN budget_tips.is_ai_generated IS 'Flag indicating if tip was generated by AI';

-- ============================================================================
-- AUTH → PUBLIC USER SYNC
-- Auto-create a public.users row when a new user signs up via Supabase Auth
-- ============================================================================

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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- COMPLETE
-- ============================================================================

SELECT 'Itinera database schema initialized successfully!' AS status;
