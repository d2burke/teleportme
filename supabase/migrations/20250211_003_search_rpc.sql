-- ============================================================
-- TeleportMe — Fuzzy City Search RPC
-- ============================================================

-- Requires pg_trgm extension (created in initial schema)

-- Set a lower similarity threshold for broader fuzzy matches
-- Default is 0.3 — we use 0.15 to catch partial city names
create or replace function public.search_cities(search_term text)
returns setof public.cities as $$
begin
    return query
    select *
    from public.cities
    where
        similarity(name, search_term) > 0.15
        or similarity(full_name, search_term) > 0.15
        or similarity(country, search_term) > 0.15
    order by
        greatest(
            similarity(name, search_term),
            similarity(full_name, search_term),
            similarity(country, search_term)
        ) desc
    limit 20;
end;
$$ language plpgsql stable;
