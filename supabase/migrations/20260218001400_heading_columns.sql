-- Add heading columns to explorations table
ALTER TABLE explorations
  ADD COLUMN IF NOT EXISTS heading_name TEXT,
  ADD COLUMN IF NOT EXISTS heading_emoji TEXT,
  ADD COLUMN IF NOT EXISTS heading_color TEXT,
  ADD COLUMN IF NOT EXISTS heading_top_signals TEXT[];

-- Add heading columns to user_preferences table
ALTER TABLE user_preferences
  ADD COLUMN IF NOT EXISTS heading_name TEXT,
  ADD COLUMN IF NOT EXISTS heading_emoji TEXT;
