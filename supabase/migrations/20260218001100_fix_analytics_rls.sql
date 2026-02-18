-- Fix analytics_events RLS policies.
--
-- Problem: When an authenticated user flushes analytics events that were
-- queued *before* sign-in, those events have user_id = NULL.  The SDK sends
-- the request with the user's auth token (so auth.uid() IS NOT NULL), but
-- neither policy matched:
--   - insert_authenticated required auth.uid() = user_id  → fails (user_id IS NULL)
--   - insert_anonymous   required user_id IS NULL          → only works when
--     auth.uid() IS NULL (anon session), not when authenticated
--
-- Fix: Replace both policies with a single policy that allows inserts when
-- user_id matches auth.uid() OR user_id is NULL (pre-auth / anonymous events).

DROP POLICY IF EXISTS "insert_authenticated" ON public.analytics_events;
DROP POLICY IF EXISTS "insert_anonymous" ON public.analytics_events;

CREATE POLICY "insert_events" ON public.analytics_events
    FOR INSERT WITH CHECK (
        user_id IS NULL OR user_id = auth.uid()
    );
