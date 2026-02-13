# TeleportMe

A lifestyle-driven city discovery app for iOS. Answer a few questions about how you want to live — climate, walkability, food scene, cost of living, and more — and TeleportMe uses AI-powered analysis to recommend cities that match your ideal lifestyle.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Client** | SwiftUI (iOS 17+) |
| **Backend** | Supabase (Auth, Database, Edge Functions) |
| **AI** | OpenAI-powered lifestyle analysis |

## Getting Started

### Prerequisites

- Xcode 15+ (with iOS 17 SDK)
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
│   ├── Config/            # Secrets & configuration
│   ├── Core/
│   │   ├── Models/        # Data models
│   │   ├── Services/      # Supabase & API service layer
│   │   ├── Navigation/    # App navigation
│   │   ├── Utilities/     # Helpers & extensions
│   │   ├── Design/        # Design tokens & shared UI
│   │   └── Debug/         # Debug utilities
│   ├── Features/
│   │   ├── Onboarding/    # Lifestyle questionnaire
│   │   ├── Discovery/     # City browsing & exploration
│   │   ├── Results/       # AI-powered match results
│   │   └── Tabs/          # Tab bar & root navigation
│   └── Resources/         # Assets & resources
├── supabase/              # Supabase migrations, edge functions & seed data
├── docs/                  # Documentation & project website
└── web/                   # Marketing / landing page assets
```

## Documentation

See [`docs/TRD.md`](docs/TRD.md) for the full Technical Requirements Document covering architecture, data models, API design, and deployment details.

## License

This project is proprietary. All rights reserved.
