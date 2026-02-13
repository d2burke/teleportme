-- Migration: Create explorations table
-- This replaces the city_reports table conceptually.
-- city_reports is kept for backward compatibility during migration.

CREATE TABLE public.explorations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title text NOT NULL DEFAULT 'Untitled Exploration',
    start_type text NOT NULL DEFAULT 'city_i_love',
    baseline_city_id text REFERENCES public.cities(id),
    preferences jsonb NOT NULL DEFAULT '{}',
    results jsonb NOT NULL DEFAULT '[]',
    ai_summary text,
    vibe_tags uuid[] DEFAULT '{}',
    free_text text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX explorations_user_id_idx ON public.explorations (user_id);
CREATE INDEX explorations_created_at_idx ON public.explorations (created_at DESC);

-- Auto-update timestamp trigger
CREATE TRIGGER explorations_updated_at
    BEFORE UPDATE ON public.explorations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Row Level Security
ALTER TABLE public.explorations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own explorations"
    ON public.explorations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own explorations"
    ON public.explorations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own explorations"
    ON public.explorations FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own explorations"
    ON public.explorations FOR DELETE
    USING (auth.uid() = user_id);
