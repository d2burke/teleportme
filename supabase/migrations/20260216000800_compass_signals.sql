-- Trip Compass: Add signal weights, compass vibes, and compass constraints
-- Signal weights persist the user's heading across sessions
-- Compass vibes/constraints are per-exploration data

-- Add signal_weights JSONB column to user_preferences
ALTER TABLE public.user_preferences
ADD COLUMN IF NOT EXISTS signal_weights jsonb DEFAULT NULL;

-- Add compass_vibes and compass_constraints to explorations
ALTER TABLE public.explorations
ADD COLUMN IF NOT EXISTS compass_vibes jsonb DEFAULT NULL,
ADD COLUMN IF NOT EXISTS compass_constraints jsonb DEFAULT NULL;

-- Comment for documentation
COMMENT ON COLUMN public.user_preferences.signal_weights IS 'Persistent heading signal weights. JSON object mapping signal keys (climate, cost, culture, safety, career, nature, food, nightlife) to weights (0-3). Evolves over time as user creates explorations.';
COMMENT ON COLUMN public.explorations.compass_vibes IS 'Per-exploration signal weights from the Trip Compass. JSON object mapping signal keys to weights.';
COMMENT ON COLUMN public.explorations.compass_constraints IS 'Per-exploration constraints from the Trip Compass. JSON object with travel_distance, safety_comfort, budget_vibe fields.';
