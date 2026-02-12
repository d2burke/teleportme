# Supabase Backend Setup

## Prerequisites
- Supabase CLI (`brew install supabase/tap/supabase`)
- Supabase project at `REDACTED_PROJECT_REF.supabase.co`
- OpenAI API key

## 1. Link to Remote Project

```bash
cd supabase
supabase link --project-ref REDACTED_PROJECT_REF
```

## 2. Run Migrations (if tables don't exist yet)

The schema and seed data are already deployed. If you need to apply new migrations:

```bash
supabase db push
```

Migrations in order:
1. `20250211_001_initial_schema.sql` — Tables, indexes, triggers
2. `20250211_002_rls_policies.sql` — Row Level Security
3. `20250211_003_search_rpc.sql` — Fuzzy city search function

## 3. Deploy Edge Functions

### Set secrets on the remote project:

```bash
supabase secrets set OPENAI_API_KEY=sk-your-key-here
```

Note: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are automatically available to Edge Functions.

### Deploy the generate-report function:

```bash
supabase functions deploy generate-report
```

### Test locally:

```bash
# Create supabase/functions/.env with your keys (see .env.example)
supabase functions serve generate-report --env-file functions/.env
```

Then call it:

```bash
curl -X POST http://localhost:54321/functions/v1/generate-report \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "current_city_id": "san-francisco",
    "preferences": { "cost": 8, "climate": 6, "culture": 7, "job_market": 5 }
  }'
```

## 4. Verify RLS Policies

After applying the RLS migration, verify policies are active:

```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;
```

## Database Tables

| Table | Purpose | RLS |
|-------|---------|-----|
| `profiles` | User profiles (extends auth.users) | Private per user |
| `cities` | 55 cities with metadata | Public read |
| `city_scores` | 17 score categories per city | Public read |
| `vibe_tags` | Lifestyle vibe categories | Public read |
| `city_vibe_tags` | City-to-vibe associations | Public read |
| `user_preferences` | User preference snapshots | Private per user |
| `city_reports` | Generated recommendation reports | Private per user |
| `saved_cities` | User bookmarked cities | Private per user |
| `engagement_events` | Analytics events | Private per user |
