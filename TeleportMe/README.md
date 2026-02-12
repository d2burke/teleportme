# Teleport.me — iOS App

## Xcode Project Setup

### 1. Create New Xcode Project
1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Settings:
   - Product Name: `TeleportMe`
   - Organization: your org
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 17.0**
4. Create the project

### 2. Add Supabase Swift Package
1. **File → Add Package Dependencies**
2. Enter URL: `https://github.com/supabase/supabase-swift`
3. Dependency Rule: **Up to Next Major Version** (start from `2.0.0`)
4. Add to target: `TeleportMe`
5. Select these products:
   - `Supabase` (the main umbrella package)

### 3. Copy Source Files
Replace the generated `ContentView.swift` and app file with the files from this folder.

**Recommended approach:** Drag the entire folder structure into Xcode:

```
TeleportMe/
├── TeleportMeApp.swift
├── Core/
│   ├── Design/
│   │   ├── TeleportTheme.swift
│   │   └── Components.swift
│   ├── Models/
│   │   └── Models.swift
│   ├── Services/
│   │   ├── SupabaseManager.swift
│   │   ├── AuthService.swift
│   │   ├── CityService.swift
│   │   └── ReportService.swift
│   └── Navigation/
│       ├── AppCoordinator.swift
│       └── RootView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── SplashView.swift
│   │   ├── NameInputView.swift
│   │   ├── SignUpView.swift
│   │   └── StartTypeView.swift
│   ├── Discovery/
│   │   ├── CitySearchView.swift
│   │   ├── CityBaselineView.swift
│   │   └── PreferencesView.swift
│   └── Results/
│       ├── GeneratingView.swift
│       └── RecommendationsView.swift
└── Resources/
    └── teleport_cities.json          ← Add to target (bundle resource)
```

### 4. Configure Supabase Credentials
Open `Core/Services/SupabaseManager.swift` and replace the placeholder values:
```swift
let url = URL(string: "https://REDACTED_PROJECT_REF.supabase.co")!
let key = "your-anon-key-here"
```

Get these from your `teleport.env` file.

### 5. Add teleport_cities.json to Bundle
1. Select `teleport_cities.json` in Xcode
2. In the File Inspector (right panel), check **Target Membership → TeleportMe**
3. Ensure "Copy Bundle Resources" includes it in Build Phases

### 6. Build & Run
1. Select an iPhone 15 Pro simulator (or physical device)
2. Build & Run (⌘R)
3. You should see the Splash screen with "Meet your ideal city in minutes"

## Architecture Overview

```
TeleportMeApp
  └─ RootView (switches on AppCoordinator.currentScreen)
       ├─ SplashView → taps "Let's roll"
       ├─ OnboardingFlowView (step-by-step)
       │    ├─ NameInputView
       │    ├─ SignUpView (creates Supabase auth account)
       │    ├─ StartTypeView (3 paths)
       │    ├─ CitySearchView (search + select current city)
       │    ├─ CityBaselineView (shows current city scores from Supabase)
       │    ├─ PreferencesView (4 sliders)
       │    ├─ GeneratingView (calls edge function)
       │    └─ RecommendationsView (shows results)
       └─ MainTabView
            ├─ Discover (placeholder)
            ├─ Saved (placeholder)
            ├─ Map (placeholder)
            └─ Profile (with sign out)
```

## Key Patterns

- **`@Observable` + `@Environment`**: iOS 17 observation framework — no `ObservableObject`/`@Published` needed
- **`AppCoordinator`**: Single source of truth for navigation, holds all services
- **Services**: Thin wrappers around Supabase client calls
- **Components**: Reusable design system in `Components.swift`
- **Theme**: All colors, fonts, spacing in `TeleportTheme`

## What's Wired Up

- ✅ Supabase auth (sign up with email/password)
- ✅ City data from Supabase (55 cities, 17 score categories)
- ✅ City search (local + server-side fuzzy via pg_trgm)
- ✅ Edge function call for report generation
- ✅ Full onboarding flow (8 screens)
- ✅ Design system matching Figma

## What's Next (Placeholder)

- Discover tab → city feed / browse experience
- Saved tab → saved cities with scores
- Map tab → MapKit integration
- Profile → preferences editing, past reports
- "A place that feels like me" path (vibe tags)
- "My own words" path (AI chat)
- Share report functionality
- Apple Sign-In
