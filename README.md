# TeleportMe

A lifestyle-driven city discovery app for iOS. Create named "Explorations" describing how you want to live — climate, culture, cost of living, job market — and TeleportMe uses AI-powered analysis to recommend cities that match your ideal lifestyle. Save favorites, browse an interactive map, and compare multiple explorations over time.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Client** | SwiftUI (iOS 17+, iOS 26 liquid glass design) |
| **AppClip** | Lightweight onboarding flow (< 10MB) |
| **Backend** | Supabase (Auth, Database, Edge Functions) |
| **AI** | OpenAI GPT-4o-mini powered city matching |

## Getting Started

### Prerequisites

- Xcode 26+ (with iOS 26 SDK) — iOS 17+ deployment target
- A [Supabase](https://supabase.com) project (free tier works)

### Setup

1. **Clone the repo**

   ```bash
   git clone https://github.com/<your-org>/TeleportMe.git
   cd TeleportMe
   ```

2. **Add your Supabase credentials**

   ```bash
   cp TeleportMe/Config/Secrets.swift.example TeleportMe/Config/Secrets.swift
   ```

   Open `TeleportMe/Config/Secrets.swift` and fill in your **Supabase URL** and **anon key**.
   You can find these in your Supabase dashboard under **Settings > API**.

   > **Note:** `Secrets.swift` is gitignored and must never be committed.

3. **Open in Xcode and run**

   ```bash
   open TeleportMe.xcodeproj
   ```

   Select a simulator or device target, then build and run (**Cmd+R**).

## Project Structure

```
TeleportMe/
├── TeleportMe/
│   ├── Config/                # Secrets & configuration
│   ├── Core/
│   │   ├── Models/            # Data models (City, Exploration, CityMatch, etc.)
│   │   ├── Services/          # ExplorationService, CityService, AuthService, etc.
│   │   ├── Navigation/        # AppCoordinator, RootView, tab routing
│   │   ├── Utilities/         # CacheManager, AsyncHelpers
│   │   ├── Design/            # TeleportTheme, reusable Components
│   │   └── Debug/             # DevModeView (DEBUG only)
│   ├── Features/
│   │   ├── Onboarding/        # Sign up + initial exploration flow
│   │   ├── Discovery/         # City search, baseline, preferences
│   │   ├── Results/           # Report generation & recommendations
│   │   ├── NewExploration/    # Modal flow for creating new explorations
│   │   ├── Exploration/       # ExplorationDetailView
│   │   ├── Profile/           # EditProfileView
│   │   └── Tabs/              # Discover, Saved, Search, Map, Profile
│   └── Resources/             # Assets & resources
├── Clip/                      # AppClip target (preferences → results → upsell)
├── supabase/                  # Migrations, edge functions & seed data
├── docs/                      # TRD, AASA, documentation
└── web/                       # Marketing / landing page assets
```

## Documentation

See [`docs/TRD.md`](docs/TRD.md) for the full Technical Requirements Document covering architecture, data models, API design, and deployment details.

## Key Features

- **Multiple Explorations** — Create named explorations with different preferences and compare results
- **iOS 26 Search Tab** — Liquid glass search tab with city browse, trending, and search
- **Interactive Map** — MapKit view with city pins, explored/saved filters, and detail cards
- **Profile Editing** — Update name, home city, and default preferences
- **AppClip** — Lightweight onboarding via NFC/QR (preferences → 3 matches → full app upsell)
- **Offline-First** — TTL-based disk caching with cache-then-network pattern
- **AI-Powered Matching** — Algorithmic scoring refined by GPT-4o-mini with personalized insights

## AppClip

The `TeleportMeClip` target provides a minimal exploration experience:
1. User adjusts 4 preference sliders
2. Edge function generates top 3 city matches
3. Results shown with AI insights
4. StoreKit overlay prompts full app download

**Bundle ID:** `app.TeleportMe.Clip`
**Size target:** < 10MB

> **Note:** The AppClip target must be added to the Xcode project manually (File → New → Target → App Clip).

## License

This project is proprietary. All rights reserved.
