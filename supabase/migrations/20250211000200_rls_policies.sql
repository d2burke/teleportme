-- ============================================================
-- TeleportMe — Row Level Security Policies
-- ============================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.cities enable row level security;
alter table public.city_scores enable row level security;
alter table public.vibe_tags enable row level security;
alter table public.city_vibe_tags enable row level security;
alter table public.user_preferences enable row level security;
alter table public.city_reports enable row level security;
alter table public.saved_cities enable row level security;
alter table public.engagement_events enable row level security;

-- ============================================================
-- PROFILES
-- ============================================================
-- Users can read their own profile
create policy "Users can view own profile"
    on public.profiles for select
    using (auth.uid() = id);

-- Users can update their own profile
create policy "Users can update own profile"
    on public.profiles for update
    using (auth.uid() = id);

-- Allow insert from trigger (service role)
create policy "Service can create profiles"
    on public.profiles for insert
    with check (auth.uid() = id);

-- ============================================================
-- CITIES (public read)
-- ============================================================
create policy "Cities are publicly readable"
    on public.cities for select
    using (true);

-- ============================================================
-- CITY SCORES (public read)
-- ============================================================
create policy "City scores are publicly readable"
    on public.city_scores for select
    using (true);

-- ============================================================
-- VIBE TAGS (public read)
-- ============================================================
create policy "Vibe tags are publicly readable"
    on public.vibe_tags for select
    using (true);

create policy "City vibe tags are publicly readable"
    on public.city_vibe_tags for select
    using (true);

-- ============================================================
-- USER PREFERENCES (private per user)
-- ============================================================
create policy "Users can view own preferences"
    on public.user_preferences for select
    using (auth.uid() = user_id);

create policy "Users can insert own preferences"
    on public.user_preferences for insert
    with check (auth.uid() = user_id);

create policy "Users can update own preferences"
    on public.user_preferences for update
    using (auth.uid() = user_id);

create policy "Users can delete own preferences"
    on public.user_preferences for delete
    using (auth.uid() = user_id);

-- ============================================================
-- CITY REPORTS (private per user)
-- ============================================================
create policy "Users can view own reports"
    on public.city_reports for select
    using (auth.uid() = user_id);

create policy "Users can insert own reports"
    on public.city_reports for insert
    with check (auth.uid() = user_id);

-- ============================================================
-- SAVED CITIES (private per user)
-- ============================================================
create policy "Users can view own saved cities"
    on public.saved_cities for select
    using (auth.uid() = user_id);

create policy "Users can save cities"
    on public.saved_cities for insert
    with check (auth.uid() = user_id);

create policy "Users can unsave cities"
    on public.saved_cities for delete
    using (auth.uid() = user_id);

-- ============================================================
-- ENGAGEMENT EVENTS (insert-only for users, read own)
-- ============================================================
create policy "Users can view own events"
    on public.engagement_events for select
    using (auth.uid() = user_id);

create policy "Users can log events"
    on public.engagement_events for insert
    with check (auth.uid() = user_id);
