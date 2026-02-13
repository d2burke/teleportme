# TeleportMe - Technical Requirements Document

**Version:** 1.0
**Date:** February 12, 2026
**Status:** Retroactive (MVP in development)
**Audience:** Principal Architects, Engineering Teams, Agent Teams

---

## 1. Executive Summary

TeleportMe is an iOS-native city relocation discovery app. Users describe their lifestyle preferences, and the system recommends cities worldwide that match their priorities across cost, climate, culture, and job market dimensions. The app combines algorithmic scoring with GPT-4o-mini refinement to produce personalized city matches with AI-generated insights.

**Architecture class:** Client-heavy SwiftUI app with Supabase BaaS (Backend-as-a-Service) and a single Edge Function for AI-powered report generation.

**Current state:** MVP with 55 seeded cities, 17 score categories per city, onboarding flow, report generation, saved cities, and offline-first caching.

---

## 2. System Architecture Overview

```
+----------------------------------------------------------+
|                     iOS Client (SwiftUI)                  |
|                                                           |
|  +----------------------------------------------------+  |
|  |                    Presentation                     |  |
|  |  RootView -> OnboardingFlowView / MainTabView      |  |
|  |  (NavigationStack + TabView, 12 feature views)     |  |
|  +----------------------------------------------------+  |
|  |                    Coordination                     |  |
|  |  AppCoordinator (@Observable)                       |  |
|  |  - Navigation state (screen + path)                 |  |
|  |  - Onboarding state (name, city, prefs)             |  |
|  |  - Service orchestration                            |  |
|  +----------------------------------------------------+  |
|  |                    Service Layer                     |  |
|  |  AuthService | CityService | ReportService          |  |
|  |  SavedCitiesService                                 |  |
|  |  (All @Observable, all use withTimeout())           |  |
|  +----------------------------------------------------+  |
|  |                    Persistence                      |  |
|  |  CacheManager (JSON files, TTL, per-user scoping)  |  |
|  +----------------------------------------------------+  |
|                          |                                |
|                   HTTPS (REST API)                        |
+----------------------------------------------------------+
                          |
+----------------------------------------------------------+
|                    Supabase Cloud                         |
|                                                           |
|  +------------------+  +-----------------------------+   |
|  |   Auth (GoTrue)  |  |   PostgREST API             |   |
|  |   JWT sessions   |  |   Auto-generated REST       |   |
|  +------------------+  |   from PostgreSQL schema     |   |
|                        +-----------------------------+   |
|  +------------------+  +-----------------------------+   |
|  |  Edge Functions  |  |   PostgreSQL 17              |   |
|  |  (Deno runtime)  |  |   8 tables, RLS policies    |   |
|  |  generate-report |  |   pg_trgm fuzzy search      |   |
|  +------------------+  +-----------------------------+   |
|                                    |                      |
|                           +--------+--------+             |
|                           |   OpenAI API    |             |
|                           |   GPT-4o-mini   |             |
|                           +-----------------+             |
+----------------------------------------------------------+
```

---

## 3. Client Architecture

### 3.1 Platform & Dependencies

| Attribute | Value |
|-----------|-------|
| Platform | iOS 17+ (SwiftUI) |
| Language | Swift 6 (strict concurrency) |
| Min deployment | iOS 17.0 |
| Architecture | arm64 (simulator + device) |
| State management | `@Observable` (Observation framework) |
| Navigation | `NavigationStack` with typed `NavigationPath` |
| Package manager | Swift Package Manager |
| External dependencies | `supabase-swift` v2.33.1 (Auth, PostgREST, Functions, Realtime, Storage) |
| Color scheme | Dark only (enforced) |
| Bundle ID | `app.TeleportMe` |

### 3.2 Layer Architecture

**Presentation Layer** (12 feature views + 11 reusable components)

All views are pure SwiftUI. No UIKit wrapping except for `UINavigationBarAppearance` configuration in the app entry point. Views access shared state through `@Environment(AppCoordinator.self)` and create local bindings with `@Bindable` when two-way binding is needed.

**Coordination Layer** (AppCoordinator)

Single `@Observable` coordinator manages:
- Screen routing (`AppScreen` enum: splash, onboarding, main)
- Onboarding navigation via `NavigationPath` with `OnboardingStep` enum (8 steps)
- All shared onboarding state (name, selected city, preferences)
- Service lifecycle and orchestration
- Cache restoration on app relaunch
- Sign-out with full state cleanup

**Service Layer** (4 services + SupabaseManager)

Each service encapsulates a domain: authentication, cities, reports, saved cities. All services are `@Observable` singletons owned by the coordinator. Every network call is wrapped with `withTimeout()` for deadline-based cancellation using structured concurrency (`withThrowingTaskGroup`).

**Persistence Layer** (CacheManager)

JSON-file-based caching in `Application Support/TeleportMe/Cache/` with:
- Global cache directory for shared data (cities, scores)
- Per-user directories keyed by UUID for private data
- TTL-based staleness checking via `CachedData<T>` wrapper
- Atomic writes, automatic corrupt file deletion

### 3.3 File Inventory

```
TeleportMe/
  TeleportMeApp.swift                          # App entry, nav bar config, DEBUG_SCREEN
  Core/
    Navigation/
      AppCoordinator.swift                     # Central state + navigation coordinator
      RootView.swift                           # Root router, OnboardingFlowView, MainTabView
    Models/
      Models.swift                             # All Codable data models (14 types)
    Services/
      SupabaseManager.swift                    # Supabase client singleton
      AuthService.swift                        # Sign up, sign in, sign out, profile CRUD
      CityService.swift                        # City fetching, search, scores (cached)
      ReportService.swift                      # Report generation + past reports (cached)
      SavedCitiesService.swift                 # Save/unsave with optimistic updates (cached)
    Utilities/
      CacheManager.swift                       # Disk cache with TTL + per-user scoping
      AsyncHelpers.swift                       # withTimeout(), Collection[safe:]
    Design/
      TeleportTheme.swift                      # Colors, typography, spacing, radii
      Components.swift                         # 8 reusable components
      PreviewHelpers.swift                     # Mock data + PreviewContainer
    Debug/
      DevModeView.swift                        # DEBUG-only dev tools panel
  Features/
    Onboarding/
      SplashView.swift                         # Landing screen
      NameInputView.swift                      # Collect user name
      SignUpView.swift                         # Email/password registration + validation
      SignInView.swift                         # Email/password login
      StartTypeView.swift                      # Choose start type
    Discovery/
      CitySearchView.swift                     # Search + trending cities
      CityBaselineView.swift                   # Selected city metrics display
      PreferencesView.swift                    # 4 preference sliders
    Results/
      GeneratingView.swift                     # Loading animation during report gen
      RecommendationsView.swift                # Match cards + comparison metrics
      ReportDetailView.swift                   # Individual report detail
    Tabs/
      DiscoverView.swift                       # Browse/search tab
      SavedView.swift                          # Saved cities tab
      MapView.swift                            # Map visualization tab (placeholder)
      ProfileView.swift                        # User profile + settings + sign out
```

### 3.4 Navigation Model

**Screen transitions:**
```
splash --> onboarding --> main
  ^                        |
  +--- signOut() ----------+
```

**Onboarding path (NavigationStack):**
```
NameInput -> SignUp -> StartType -> CitySearch -> CityBaseline -> Preferences -> Generating -> Recommendations
```

The `generating -> recommendations` transition is a **replace** (removeLast + append) to prevent back-swiping to the loading screen.

**Main tabs (TabView):**
```
Discover | Saved | Map | Profile
```

Each tab manages its own internal navigation. ProfileView uses a local `NavigationStack` for report detail drill-down.

### 3.5 State Management Pattern

```swift
// Coordinator owns services and state
@Observable final class AppCoordinator {
    let authService = AuthService()
    let cityService = CityService()
    // ... injected into environment at app root
}

// Views read from environment
struct SomeView: View {
    @Environment(AppCoordinator.self) private var coordinator

    // For two-way bindings:
    @Bindable var coord = coordinator
    // Now $coord.preferences.costPreference works as a Binding
}
```

### 3.6 Caching Strategy

| Cache Key | Scope | TTL | Write Trigger |
|-----------|-------|-----|---------------|
| `cities` | Global | 24h | `fetchAllCities()` network success |
| `cityScores` | Global | 24h | `getCityWithScores()` network success |
| `savedCities(userId)` | Per-user | 5min | Every save/unsave (optimistic + confirmed) |
| `currentReport(userId)` | Per-user | None | `generateReport()` success |
| `pastReports(userId)` | Per-user | 1h | `loadReports()` network success |
| `preferences(userId)` | Per-user | None | `savePreferences()` |
| `selectedCity(userId)` | Per-user | None | `selectCity()` |

**Cache-then-network pattern:**
1. Load from disk cache -> populate `@Observable` properties instantly
2. If cache is fresh (within TTL) and non-empty, skip network
3. Otherwise fetch from Supabase in background
4. On success -> update properties + write-through to cache
5. On failure -> keep cached data displayed, only show error if cache was empty

**Optimistic update pattern (SavedCitiesService):**
1. Update local state + write cache immediately
2. Send network request in background
3. On success -> replace optimistic entry with server response + write cache
4. On failure -> rollback local state + write cache (rollback state)

### 3.7 Error Handling Strategy

Every service follows a consistent pattern:
- `withTimeout(seconds:)` wraps all Supabase calls (10-30s depending on operation)
- `isLoading` / `loadError` observable properties drive UI states
- Views show three-state UI: loading spinner -> error with retry -> content
- Errors only surface when no cached data is available
- All errors are user-facing (`localizedDescription`) with retry affordance

### 3.8 Design System

**Color palette (dark theme only):**

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0A0A0A` | App background |
| `surface` | `#1A1A1A` | Card backgrounds |
| `surfaceElevated` | `#222222` | Active/selected states |
| `border` | `#2A2A2A` | Dividers, inactive bars |
| `accent` | `#D4FF00` | Primary CTA, highlights (lime) |
| `textPrimary` | `#FFFFFF` | Headings, primary text |
| `textSecondary` | `#8E8E93` | Labels, descriptions |
| `textTertiary` | `#636366` | Placeholders, metadata |

**Typography scale:** System font with 7 semantic styles (heroTitle 40px -> caption 12px). Score values use `.rounded` design variant.

**Spacing scale:** 4px increments (xs:4, sm:8, md:16, lg:24, xl:32, xxl:48)

**Corner radius scale:** small:8, medium:12, card:16, large:20, pill:28

**Reusable components:** TeleportButton (3 styles), CardView, ScoreBar, ComparisonBar, MetricCard, TrendingChip, SectionHeader, CityHeroImage, PreferenceSliderCard

---

## 4. Service-Side Architecture

### 4.1 Supabase Configuration

| Service | Details |
|---------|---------|
| Project ref | `REDACTED_PROJECT_REF` |
| Region | (Supabase-managed) |
| PostgreSQL | v17 |
| Auth | GoTrue (email/password, JWT, 1h token expiry) |
| API | PostgREST (auto-generated REST from schema) |
| Edge Functions | Deno v1 runtime, oneshot policy |
| Realtime | Enabled (not yet used by client) |
| Storage | Enabled (not yet used by client) |

### 4.2 Database Schema

**8 tables across 3 categories:**

**Reference data (public read, admin write):**

```sql
cities (
    id text PRIMARY KEY,           -- slug: "san-francisco"
    name text NOT NULL,            -- "San Francisco"
    full_name text NOT NULL,       -- "San Francisco, California"
    country text NOT NULL,
    continent text NOT NULL,
    latitude double precision,
    longitude double precision,
    population integer,
    teleport_city_score double precision,
    summary text,
    image_url text,
    created_at timestamptz,
    updated_at timestamptz
)

city_scores (
    id uuid PRIMARY KEY,
    city_id text REFERENCES cities(id) ON DELETE CASCADE,
    category text NOT NULL,        -- 17 categories per city
    score double precision,        -- 0-10 scale
    UNIQUE(city_id, category)
)

vibe_tags (id, name, emoji, category)
city_vibe_tags (city_id, vibe_tag_id, strength)  -- junction table
```

**User data (private per user via RLS):**

```sql
profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name text,
    email text,
    current_city_id text,
    avatar_url text,
    created_at timestamptz,
    updated_at timestamptz
)

user_preferences (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id),
    start_type text DEFAULT 'city_i_love',
    cost_preference double precision DEFAULT 5.0,
    climate_preference double precision DEFAULT 5.0,
    culture_preference double precision DEFAULT 5.0,
    job_market_preference double precision DEFAULT 5.0,
    selected_vibe_tags uuid[],
    dealbreakers text[]
)

city_reports (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id),
    current_city_id text REFERENCES cities(id),
    preferences jsonb,             -- snapshot of user prefs at generation time
    results jsonb,                 -- array of CityMatch objects
    ai_summary text
)

saved_cities (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id),
    city_id text REFERENCES cities(id),
    UNIQUE(user_id, city_id)
)

engagement_events (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id),
    event_type text,
    metadata jsonb
)
```

### 4.3 Row Level Security

All tables have RLS enabled. Policy summary:

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| profiles | Own only | Own (via trigger) | Own only | - |
| cities | Public | - | - | - |
| city_scores | Public | - | - | - |
| vibe_tags | Public | - | - | - |
| city_vibe_tags | Public | - | - | - |
| user_preferences | Own only | Own only | Own only | Own only |
| city_reports | Own only | Own only | - | - |
| saved_cities | Own only | Own only | - | Own only |
| engagement_events | Own only | Own only | - | - |

### 4.4 Database Functions

**`search_cities(search_term text)`** - Fuzzy city search using `pg_trgm` extension. Similarity threshold of 0.15 across name, full_name, and country. Returns top 20 results ordered by best similarity score.

**`handle_new_user()`** - Trigger function that auto-creates a `profiles` row when a new `auth.users` row is inserted.

**`update_updated_at()`** - Generic trigger function that sets `updated_at = now()` on row updates. Applied to profiles, cities, user_preferences.

### 4.5 Indexes

```sql
-- Fuzzy search (GIN trigram)
cities_name_trgm_idx       ON cities USING gin (name gin_trgm_ops)
cities_full_name_trgm_idx  ON cities USING gin (full_name gin_trgm_ops)

-- Lookup indexes
cities_country_idx         ON cities (country)
cities_continent_idx       ON cities (continent)
city_scores_city_id_idx    ON city_scores (city_id)
user_preferences_user_id   ON user_preferences (user_id)
city_reports_user_id_idx   ON city_reports (user_id)
city_reports_created_at    ON city_reports (created_at DESC)
saved_cities_user_id_idx   ON saved_cities (user_id)
engagement_events_*        ON engagement_events (user_id, event_type, created_at DESC)
```

### 4.6 Edge Function: `generate-report`

**Runtime:** Deno v1 (Supabase Edge Functions)

**Dependencies:**
- `deno.land/std@0.177.0/http/server.ts`
- `@supabase/supabase-js@2.39.3`
- `openai@v4.38.0`

**Request:**
```json
{
    "current_city_id": "san-francisco",
    "preferences": {
        "cost": 7.0,
        "climate": 6.0,
        "culture": 8.0,
        "job_market": 5.0
    }
}
```

**Algorithm:**
1. Authenticate user from JWT in Authorization header
2. Fetch current city + its 17 scores
3. Fetch all candidate cities (excluding current) + all scores
4. **Algorithmic scoring** for each candidate:
   - Weighted sum: `(pref_weight/10) * (city_score/10) * 100` for 4 primary categories
   - Bonus: 5 additional categories (Safety, Healthcare, Commute, Internet, Tolerance) at 10% weight each
   - Clamp result to 40-99%
5. Take top 8 candidates
6. **GPT-4o-mini refinement:** Send top 8 with scores and user prefs. GPT picks 3-5 best matches and writes 1-sentence personalized insights per city
7. Parse GPT JSON response; validate city IDs against candidate pool
8. **Fallback:** If GPT parse fails, use top 4 algorithmic picks with generic insights
9. Build comparison metrics for 5 display categories (cost, climate, culture, economy, commute)
10. Save report to `city_reports` table (if authenticated)
11. Return structured response

**Response:**
```json
{
    "report_id": "uuid",
    "current_city": {
        "id": "san-francisco",
        "name": "San Francisco",
        "scores": { "Cost of Living": 2.5, ... }
    },
    "matches": [
        {
            "city_id": "berlin",
            "city_name": "Berlin",
            "city_full_name": "Berlin, Germany",
            "city_country": "Germany",
            "city_image_url": "https://...",
            "match_percent": 87,
            "rank": 1,
            "comparison": {
                "Cost of Living": {
                    "match_score": 7.0,
                    "current_score": 2.5,
                    "delta": 4.5
                }
            },
            "ai_insight": "Berlin offers...",
            "scores": { ... }
        }
    ]
}
```

**Timeout:** 30s client-side. Edge function has no explicit timeout (Supabase default applies).

### 4.7 Seed Data

55 cities across 6 continents with:
- Full metadata (name, country, continent, lat/long, population, image URL)
- 17 score categories per city (935 total scores)
- Teleport city scores (overall quality-of-life index)

Score categories: Housing, Cost of Living, Startups, Venture Capital, Travel Connectivity, Commute, Business Freedom, Safety, Healthcare, Education, Environmental Quality, Economy, Taxation, Internet Access, Leisure & Culture, Tolerance, Outdoors

---

## 5. Data Flow Diagrams

### 5.1 App Relaunch (Returning User)

```
App Launch
  |
  v
RootView.onAppear
  |
  v
AppCoordinator.checkExistingSession()
  |
  +-> AuthService.checkSession()
  |     +-> supabase.auth.session (10s timeout)
  |     +-> AuthService.loadProfile()
  |
  +-> (If authenticated) restoreCachedState(userId)
  |     +-> CacheManager.load(preferences)    -> coordinator.preferences
  |     +-> CacheManager.load(currentReport)  -> reportService.currentReport
  |     +-> CacheManager.load(selectedCity)   -> coordinator.selectedCity
  |
  +-> CityService.fetchAllCities()
  |     +-> CacheManager.load(cities)         -> allCities (instant)
  |     +-> (If stale) Fetch from Supabase    -> write-through cache
  |
  +-> goToMain()
        +-> MainTabView displays with cached data
```

### 5.2 Report Generation

```
User taps "Find My Cities" on PreferencesView
  |
  v
AppCoordinator.advanceOnboarding(from: .preferences)
  +-> savePreferences()
  |     +-> CacheManager.save(preferences)
  |     +-> supabase.from("user_preferences").upsert()
  +-> navigationPath.append(.generating)
  |
  v
GeneratingView.onAppear
  +-> AppCoordinator.generateReport()
  |     +-> ReportService.generateReport(cityId, prefs, userId)
  |           +-> supabase.functions.invoke("generate-report") [30s timeout]
  |           +-> reportService.currentReport = response
  |           +-> CacheManager.save(response, .currentReport)
  |
  +-> advanceOnboarding(from: .generating)
        +-> removeLast() [.generating]
        +-> append(.recommendations)
  |
  v
RecommendationsView renders matches from reportService.currentReport
```

### 5.3 Save/Unsave City

```
User taps heart icon
  |
  v
SavedCitiesService.toggleSave(cityId)
  |
  +-> isSaved? -> unsave(cityId)
  |   +-> OPTIMISTIC: remove from savedCityIds + savedCities
  |   +-> CacheManager.save(savedCities)
  |   +-> supabase.from("saved_cities").delete().eq(...)
  |   +-> On error: ROLLBACK + CacheManager.save(rollback state)
  |
  +-> !isSaved? -> save(cityId)
      +-> OPTIMISTIC: insert into savedCityIds + savedCities
      +-> CacheManager.save(savedCities)
      +-> supabase.from("saved_cities").insert(...)
      +-> On success: replace optimistic with server response + cache
      +-> On error: ROLLBACK + CacheManager.save(rollback state)
```

---

## 6. Security Analysis

### 6.1 Current State

| Area | Status | Risk |
|------|--------|------|
| API key storage | Hardcoded in `SupabaseManager.swift` | **HIGH** - Anon key in source code |
| Authentication | Email/password via Supabase GoTrue | Medium - No MFA, no email confirmation |
| Authorization | RLS on all tables | Good - Per-user isolation enforced |
| Network | HTTPS to Supabase cloud | Good - TLS enforced |
| Local storage | JSON files in Application Support | Medium - No encryption at rest |
| Edge function auth | JWT from auth header, service role key for DB | Good - Proper separation |
| OpenAI API key | Server-side env var only | Good - Not exposed to client |
| Password policy | Min 6 chars (Supabase default) | Medium - No complexity requirements |

### 6.2 Recommendations

1. **Move API keys to Config.xcconfig** excluded from version control, or use a build-time injection mechanism
2. **Enable email confirmation** in Supabase auth config (`enable_confirmations = true`)
3. **Add cache encryption** for sensitive per-user data (consider `CryptoKit` AES-GCM wrapping)
4. **Implement certificate pinning** for production builds
5. **Add rate limiting** to edge function (currently relies on Supabase defaults)
6. **Rotate the anon key** since it's been committed to source control

---

## 7. Risks & Technical Debt

### 7.1 High Priority

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Hardcoded Supabase credentials** | Key exposure in source control | Move to `.xcconfig` or Keychain; rotate current key |
| **No test coverage** | Regressions undetectable | Add unit tests for CacheManager, services, coordinator state transitions |
| **Single edge function** | Report gen is the core feature; failure = total feature loss | Add health check endpoint; implement client-side algorithmic fallback |
| **GPT dependency** | OpenAI API outage blocks report generation | Algorithmic fallback exists but produces generic insights |
| **No CI/CD pipeline** | Manual builds, no automated verification | Set up Xcode Cloud or GitHub Actions with `xcodebuild` |

### 7.2 Medium Priority

| Risk | Impact | Mitigation |
|------|--------|------------|
| **No image caching** | City images re-downloaded every session | Integrate `AsyncImage` caching (SDWebImage/Kingfisher) or `URLCache` config |
| **No pagination** | 55 cities loads fully into memory | Fine for MVP; add cursor-based pagination before 500+ cities |
| **Cache corruption** | Auto-deleted, but user sees empty state until network fetch | Add migration versioning to cache format |
| **No analytics pipeline** | `engagement_events` table exists but client never writes events | Implement event tracking for key user actions |
| **Map tab is placeholder** | Users see an incomplete feature | Either implement MapKit integration or remove tab from MVP |
| **Vibe tags unused** | Schema exists (`vibe_tags`, `city_vibe_tags`, `user_preferences.selected_vibe_tags`) but no client integration | Wire up or remove from schema |

### 7.3 Low Priority / Future

| Item | Notes |
|------|-------|
| **No push notifications** | Config exists in Supabase but not wired to client |
| **No deep linking** | Universal links not configured |
| **No accessibility audit** | Dynamic Type, VoiceOver labels not verified |
| **No localization** | English only; strings not externalized |
| **No A/B testing** | DevModeView has placeholder for feature flags |
| **Realtime not used** | Supabase Realtime is enabled but client doesn't subscribe to changes |
| **Storage not used** | Supabase Storage enabled but no user-uploaded content |

---

## 8. Performance Characteristics

### 8.1 Current Metrics (Estimated)

| Operation | Latency | Notes |
|-----------|---------|-------|
| App launch to main screen (cached) | < 200ms | Auth session + cache restore |
| App launch to main screen (cold) | 2-5s | Auth + network fetch cities |
| City search (local) | < 10ms | In-memory filter of 55 cities |
| City search (server) | 200-500ms | pg_trgm fuzzy search |
| Report generation | 5-15s | Edge function + GPT-4o-mini |
| Save/unsave city | < 50ms | Optimistic update; network in background |
| Cache file read | < 5ms | Small JSON files (< 200KB total) |
| Cache file write | < 10ms | Atomic write, synchronous |

### 8.2 Memory Profile

- Cities array: ~55 objects, ~50KB in memory
- Score cache: ~55 dictionaries, ~30KB
- Report: 3-5 matches, < 10KB
- Total app memory: < 50MB (estimated, excluding images)

### 8.3 Disk Usage

- Cache directory: < 500KB total
- Per-user cache: < 100KB
- Global cache: < 200KB (cities + scores)

---

## 9. Improvements Roadmap

### 9.1 Phase 1: Stabilization (Current Sprint)

- [ ] Run seed data against remote database
- [ ] Unpause Supabase project and verify all endpoints
- [ ] End-to-end test: sign up -> generate report -> relaunch -> verify cache
- [ ] Fix MapView (implement or remove)
- [ ] Add basic unit tests for CacheManager and service layer

### 9.2 Phase 2: Production Readiness

- [ ] Move API credentials to secure config
- [ ] Enable email confirmation
- [ ] Add Xcode Cloud CI/CD pipeline
- [ ] Implement engagement event tracking
- [ ] Add image caching layer (URLCache or third-party)
- [ ] Error reporting (Sentry or similar)
- [ ] App Store submission preparation (screenshots, metadata)

### 9.3 Phase 3: Feature Expansion

- [ ] Vibe tags integration (browse cities by vibe)
- [ ] Interactive map with city pins and filters
- [ ] Social features (share reports, compare with friends)
- [ ] Push notifications for new city data
- [ ] Edit profile (name, avatar)
- [ ] Report comparison (side-by-side reports over time)
- [ ] City detail view (deep-dive into a single city)
- [ ] Onboarding A/B testing (start type variants)

### 9.4 Phase 4: Scale

- [ ] Expand city catalog to 200+ cities
- [ ] Add city data pipeline (automated scoring updates)
- [ ] Implement cursor-based pagination for cities
- [ ] Add CDN for city images
- [ ] Consider SwiftData for richer local storage
- [ ] WebSocket subscriptions for real-time saved cities sync
- [ ] Multi-language support

---

## 10. Development Infrastructure

### 10.1 Build Configuration

```bash
# Build command
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -scheme TeleportMe \
  -destination 'platform=iOS Simulator,id=7AE50D1F-58F8-4DF3-880F-A64C1FAD9790' \
  build

# Simulator: iPhone 17 Pro, iOS 26.2
```

### 10.2 Debug Screens

Set `SIMCTL_CHILD_DEBUG_SCREEN` environment variable to jump to specific screens:

| Value | Target Screen |
|-------|---------------|
| `cityBaseline` | CityBaselineView with mock selected city |
| `preferences` | PreferencesView with mock state |
| `generating` | GeneratingView |
| `recommendations` | RecommendationsView with mock report |
| `main` | MainTabView with mock report |

### 10.3 Preview System

All views include `#Preview` blocks using `PreviewContainer` which:
- Injects `AppCoordinator` with mock data into environment
- Applies dark color scheme
- Provides `PreviewHelpers` with sample cities, scores, matches, and reports

### 10.4 Supabase Local Development

```bash
# Start local Supabase
supabase start

# Apply migrations
supabase db reset  # runs migrations + seed.sql

# Deploy edge function
supabase functions deploy generate-report

# Required env vars for edge function:
# OPENAI_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
```

---

## 11. Glossary

| Term | Definition |
|------|------------|
| **City Score** | A 0-10 rating for a city across one of 17 quality-of-life categories |
| **Match Percent** | Algorithmic + AI-refined score (40-99%) indicating city alignment with user preferences |
| **Edge Function** | Serverless Deno function hosted on Supabase infrastructure |
| **RLS** | Row Level Security - PostgreSQL policies that restrict data access per-user |
| **TTL** | Time To Live - Duration before cached data is considered stale |
| **Write-Through** | Cache pattern where data is written to cache simultaneously with remote persistence |
| **Optimistic Update** | UI pattern where local state is updated before network confirmation, with rollback on failure |
| **pg_trgm** | PostgreSQL extension for fuzzy text matching using trigram similarity |
| **GoTrue** | Supabase's authentication service (JWT-based) |
| **PostgREST** | Supabase's auto-generated REST API from PostgreSQL schema |

---

*This document is maintained alongside the codebase and should be updated as architecture evolves.*
