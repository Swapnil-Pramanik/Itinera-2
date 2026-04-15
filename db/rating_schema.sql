-- ============================================================================
-- USER RATINGS SCHEMA
-- Individual ratings for destinations with auto-recalculation of aggregate scores
-- ============================================================================

-- 1. Create the user_ratings table
CREATE TABLE IF NOT EXISTS user_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, destination_id)
);

-- 2. Create index for performance
CREATE INDEX IF NOT EXISTS idx_user_ratings_dest_id ON user_ratings(destination_id);

-- 3. Create the function to recalculate aggregate rating
CREATE OR REPLACE FUNCTION recalculate_destination_rating()
RETURNS TRIGGER AS $$
DECLARE
    new_avg_rating DECIMAL(2,1);
    new_review_count INTEGER;
BEGIN
    -- Calculate new stats for the affected destination
    SELECT 
        COALESCE(AVG(rating), 0)::DECIMAL(2,1),
        COUNT(*)
    INTO 
        new_avg_rating,
        new_review_count
    FROM user_ratings
    WHERE destination_id = COALESCE(NEW.destination_id, OLD.destination_id);

    -- Update the destinations table
    UPDATE destinations
    SET 
        rating = new_avg_rating,
        review_count = new_review_count,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.destination_id, OLD.destination_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Create trigger to run the calculation on insert, update, or delete
DROP TRIGGER IF EXISTS trg_recalculate_rating ON user_ratings;
CREATE TRIGGER trg_recalculate_rating
AFTER INSERT OR UPDATE OR DELETE ON user_ratings
FOR EACH ROW
EXECUTE FUNCTION recalculate_destination_rating();

-- 5. Comments
COMMENT ON TABLE user_ratings IS 'Individual user ratings for travel destinations';
COMMENT ON COLUMN user_ratings.rating IS 'User rating from 1 to 5 stars';
