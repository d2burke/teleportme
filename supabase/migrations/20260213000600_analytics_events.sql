-- Analytics Events Table
-- Stores all app analytics events for funnel analysis, engagement tracking,
-- performance monitoring, and business outcome measurement.

CREATE TABLE public.analytics_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    session_id text NOT NULL,
    event_name text NOT NULL,
    screen text NOT NULL,
    properties jsonb DEFAULT '{}',
    app_version text,
    build_type text,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes for common query patterns
CREATE INDEX idx_analytics_user_id ON public.analytics_events (user_id);
CREATE INDEX idx_analytics_event_name ON public.analytics_events (event_name);
CREATE INDEX idx_analytics_created_at ON public.analytics_events (created_at DESC);
CREATE INDEX idx_analytics_screen ON public.analytics_events (screen);
CREATE INDEX idx_analytics_session ON public.analytics_events (session_id);

-- RLS: insert-only for both authenticated and anonymous users
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "insert_authenticated" ON public.analytics_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "insert_anonymous" ON public.analytics_events
    FOR INSERT WITH CHECK (user_id IS NULL);
