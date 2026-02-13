-- Add safety, commute, and healthcare preference columns to user_preferences
-- These were previously hardcoded defaults; now they are first-class user inputs.

ALTER TABLE public.user_preferences
    ADD COLUMN IF NOT EXISTS safety_preference double precision NOT NULL DEFAULT 5.0,
    ADD COLUMN IF NOT EXISTS commute_preference double precision NOT NULL DEFAULT 5.0,
    ADD COLUMN IF NOT EXISTS healthcare_preference double precision NOT NULL DEFAULT 5.0;
