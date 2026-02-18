-- City Insights: GPT-generated "Known For" and "Concerns" for each city
-- Generated on first request, cached with a 30-day TTL

CREATE TABLE IF NOT EXISTS public.city_insights (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    city_id text NOT NULL REFERENCES public.cities(id) ON DELETE CASCADE,
    known_for text[] NOT NULL DEFAULT '{}',
    concerns text[] NOT NULL DEFAULT '{}',
    generated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT unique_city_insights UNIQUE (city_id)
);

-- Index for fast lookup by city_id
CREATE INDEX IF NOT EXISTS idx_city_insights_city_id ON public.city_insights(city_id);

-- Public read access (anyone can view city insights)
ALTER TABLE public.city_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "City insights are publicly readable"
    ON public.city_insights
    FOR SELECT
    USING (true);

-- Allow the service role to insert/update (edge function uses service role key)
CREATE POLICY "Service role can manage city insights"
    ON public.city_insights
    FOR ALL
    USING (true)
    WITH CHECK (true);

COMMENT ON TABLE public.city_insights IS 'Cached GPT-generated insights for each city. Contains "known for" highlights and traveler concerns. Regenerated after 30 days.';
COMMENT ON COLUMN public.city_insights.known_for IS 'Array of 4-5 things the city is known for (e.g., "World-class street food", "Historic architecture")';
COMMENT ON COLUMN public.city_insights.concerns IS 'Array of 3-4 common traveler concerns (e.g., "High cost of living", "Language barrier")';
