-- ============================================================
-- TeleportMe MVP — Initial Schema
-- ============================================================

-- Enable required extensions
create extension if not exists "pg_trgm";    -- fuzzy text search
create extension if not exists "uuid-ossp";  -- uuid generation

-- ============================================================
-- 1. PROFILES (extends Supabase auth.users)
-- ============================================================
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    name text not null default '',
    email text,
    current_city_id text,
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, email)
    values (new.id, new.email);
    return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- Auto-update updated_at
create or replace function public.update_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
    before update on public.profiles
    for each row execute function public.update_updated_at();

-- ============================================================
-- 2. CITIES
-- ============================================================
create table public.cities (
    id text primary key,
    name text not null,
    full_name text not null,
    country text not null,
    continent text not null default '',
    latitude double precision not null default 0,
    longitude double precision not null default 0,
    population integer,
    teleport_city_score double precision,
    summary text,
    image_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Indexes for search
create index cities_name_trgm_idx on public.cities using gin (name gin_trgm_ops);
create index cities_full_name_trgm_idx on public.cities using gin (full_name gin_trgm_ops);
create index cities_country_idx on public.cities (country);
create index cities_continent_idx on public.cities (continent);

create trigger cities_updated_at
    before update on public.cities
    for each row execute function public.update_updated_at();

-- ============================================================
-- 3. CITY SCORES (17 categories per city)
-- ============================================================
create table public.city_scores (
    id uuid primary key default uuid_generate_v4(),
    city_id text not null references public.cities(id) on delete cascade,
    category text not null,
    score double precision not null default 0,
    created_at timestamptz not null default now(),
    unique(city_id, category)
);

create index city_scores_city_id_idx on public.city_scores (city_id);

-- ============================================================
-- 4. VIBE TAGS
-- ============================================================
create table public.vibe_tags (
    id uuid primary key default uuid_generate_v4(),
    name text not null unique,
    emoji text,
    category text, -- e.g. 'lifestyle', 'culture', 'pace'
    created_at timestamptz not null default now()
);

-- Junction table: cities <-> vibe_tags
create table public.city_vibe_tags (
    city_id text not null references public.cities(id) on delete cascade,
    vibe_tag_id uuid not null references public.vibe_tags(id) on delete cascade,
    strength double precision default 1.0, -- 0-1 how strongly this vibe applies
    primary key (city_id, vibe_tag_id)
);

-- ============================================================
-- 5. USER PREFERENCES
-- ============================================================
create table public.user_preferences (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    start_type text not null default 'city_i_love',
    cost_preference double precision not null default 5.0,
    climate_preference double precision not null default 5.0,
    culture_preference double precision not null default 5.0,
    job_market_preference double precision not null default 5.0,
    selected_vibe_tags uuid[] default '{}',
    dealbreakers text[] default '{}',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index user_preferences_user_id_idx on public.user_preferences (user_id);

create trigger user_preferences_updated_at
    before update on public.user_preferences
    for each row execute function public.update_updated_at();

-- ============================================================
-- 6. CITY REPORTS (generated by Edge Function)
-- ============================================================
create table public.city_reports (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    current_city_id text references public.cities(id),
    preferences jsonb not null default '{}',
    results jsonb not null default '[]',
    ai_summary text,
    created_at timestamptz not null default now()
);

create index city_reports_user_id_idx on public.city_reports (user_id);
create index city_reports_created_at_idx on public.city_reports (created_at desc);

-- ============================================================
-- 7. SAVED CITIES
-- ============================================================
create table public.saved_cities (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    city_id text not null references public.cities(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique(user_id, city_id)
);

create index saved_cities_user_id_idx on public.saved_cities (user_id);

-- ============================================================
-- 8. ENGAGEMENT EVENTS
-- ============================================================
create table public.engagement_events (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id) on delete set null,
    event_type text not null,
    metadata jsonb default '{}',
    created_at timestamptz not null default now()
);

create index engagement_events_user_id_idx on public.engagement_events (user_id);
create index engagement_events_type_idx on public.engagement_events (event_type);
create index engagement_events_created_at_idx on public.engagement_events (created_at desc);

-- ============================================================
-- 9. FUZZY SEARCH RPC
-- ============================================================
create or replace function public.search_cities(search_term text)
returns setof public.cities as $$
begin
    return query
    select *
    from public.cities
    where
        name % search_term
        or full_name % search_term
        or country % search_term
    order by
        similarity(name, search_term) desc
    limit 20;
end;
$$ language plpgsql stable;
