#!/usr/bin/env python3
"""
Assign vibe tags to 156 travel cities and upload to Supabase.

Rules-based approach using city scores, country/continent metadata,
summary keywords, and manual overrides for well-known vibes.
"""

import json
import requests
import time

# ── Vibe tag UUIDs ──────────────────────────────────────────────────────────

VIBES = {
    # CULTURE
    "Arts & Music":       "a2000000-0000-0000-0000-000000000001",
    "Bohemian":           "a2000000-0000-0000-0000-000000000004",
    "Cosmopolitan":       "a2000000-0000-0000-0000-000000000003",
    "Historic":           "a2000000-0000-0000-0000-000000000002",
    # ENVIRONMENT
    "Affordable":         "a5000000-0000-0000-0000-000000000004",
    "Digital Nomad":      "a5000000-0000-0000-0000-000000000002",
    "Startup Hub":        "a5000000-0000-0000-0000-000000000001",
    "Student Friendly":   "a5000000-0000-0000-0000-000000000003",
    # LIFESTYLE
    "Beach Life":         "a1000000-0000-0000-0000-000000000004",
    "Coffee Culture":     "a1000000-0000-0000-0000-000000000006",
    "Foodie":             "a1000000-0000-0000-0000-000000000003",
    "Luxury":             "a1000000-0000-0000-0000-000000000007",
    "Nightlife":          "a1000000-0000-0000-0000-000000000002",
    "Outdoorsy":          "a1000000-0000-0000-0000-000000000005",
    "Walkable":           "a1000000-0000-0000-0000-000000000001",
    # PACE
    "Fast-Paced":         "a3000000-0000-0000-0000-000000000001",
    "Quiet & Peaceful":   "a3000000-0000-0000-0000-000000000002",
    # VALUES
    "Eco-Conscious":      "a4000000-0000-0000-0000-000000000003",
    "Family Friendly":    "a4000000-0000-0000-0000-000000000002",
    "LGBTQ+ Friendly":   "a4000000-0000-0000-0000-000000000001",
}

# ── Supabase config ─────────────────────────────────────────────────────────

SUPABASE_URL = "https://api.supabase.com/v1/projects/fpdkmurgoqjplbbxlpkl/database/query"
SUPABASE_TOKEN = "sbp_6ae0c0d7893b10a48a85081fe71faa38250280d2"
HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0",
}

# ── Keyword / region sets ───────────────────────────────────────────────────

COASTAL_KEYWORDS = [
    "beach", "coast", "island", "sea", "ocean", "lagoon", "reef",
    "shore", "bay", "harbor", "port", "surf", "snorkel", "diving",
    "overwater", "Caribbean", "Mediterranean", "coral", "waterfront",
    "seaside", "tropical", "palm"
]

HISTORIC_KEYWORDS = [
    "ancient", "medieval", "colonial", "heritage", "temple", "ruin",
    "UNESCO", "historic", "century", "old town", "palace", "fort",
    "dynasty", "kingdom", "castle", "church", "mosque", "monastery",
    "pagoda", "stupa", "tomb", "cathedral"
]

NATURE_KEYWORDS = [
    "mountain", "hiking", "trek", "gorge", "canyon", "waterfall",
    "jungle", "forest", "volcano", "glacier", "alpine", "lake",
    "river", "nature", "wildlife", "national park", "cave", "karst",
    "fjord", "valley"
]

BOHEMIAN_KEYWORDS = [
    "bohemian", "artsy", "backpacker", "yoga", "spiritual", "laid-back",
    "hippy", "alternative", "creative", "indie", "surf", "vibe"
]

FOOD_KEYWORDS = [
    "food", "cuisine", "culinary", "gastronom", "restaurant", "market",
    "street food", "foodie", "ramen", "tapas", "spice", "wine",
    "chocolate", "tasting", "chef"
]

ART_MUSIC_KEYWORDS = [
    "art", "museum", "gallery", "music", "jazz", "dance", "theater",
    "festival", "cultural", "craft", "design", "performance", "opera",
    "salsa", "reggae", "samba"
]

NIGHTLIFE_KEYWORDS = [
    "nightlife", "party", "club", "bar", "pub", "beach club", "vibrant",
    "buzzing", "nightclub"
]

LUXURY_KEYWORDS = [
    "luxury", "upscale", "glamorous", "palatial", "exclusive", "boutique",
    "overwater", "five-star", "premium", "posh"
]

ECO_KEYWORDS = [
    "eco", "sustainable", "conservation", "wildlife", "organic",
    "pristine", "mangrove", "protected", "sanctuary"
]

COFFEE_KEYWORDS = [
    "coffee", "cafe", "tea", "bakeries"
]

# ── Countries & regions by trait ─────────────────────────────────────────────

SE_ASIAN_COUNTRIES = {
    "Thailand", "Vietnam", "Cambodia", "Laos", "Indonesia", "Philippines",
    "Myanmar", "Malaysia"
}

SOUTH_ASIAN_COUNTRIES = {
    "India", "Nepal", "Sri Lanka"
}

AFFORDABLE_COUNTRIES = SE_ASIAN_COUNTRIES | SOUTH_ASIAN_COUNTRIES | {
    "Bolivia", "Guatemala", "Morocco", "Egypt", "Tanzania", "Zambia",
    "Mexico", "Colombia", "Peru", "Ecuador", "Georgia", "Uzbekistan",
    "China", "Jordan"
}

LGBTQ_FRIENDLY_CITIES = {
    "mykonos", "san-sebastian", "san-juan", "willemstad", "bridgetown",
    "cartagena", "playa-del-carmen", "tulum", "queenstown", "dubrovnik",
    "hvar", "bruges", "colmar", "sintra", "faro", "valletta", "batumi",
    "oaxaca", "san-miguel-de-allende", "seminyak", "ubud"
}

DIGITAL_NOMAD_CITIES = {
    "chiang-mai", "ubud", "da-nang", "hoi-an", "penang", "playa-del-carmen",
    "tulum", "oaxaca", "goa", "seminyak", "koh-samui", "phuket",
    "colombo", "cartagena", "batumi", "cebu", "hanoi", "dalat",
    "fukuoka", "caye-caulker", "pai", "koh-lanta", "san-juan",
    "san-miguel-de-allende"
}

WALKABLE_CITIES = {
    "bruges", "dubrovnik", "kotor", "hallstatt", "cinque-terre", "amalfi",
    "positano", "santorini", "mykonos", "hvar", "cesky-krumlov", "valletta",
    "sintra", "colmar", "san-sebastian", "lucerne", "lake-bled", "mostar",
    "hoi-an", "luang-prabang", "cusco", "antigua-guatemala", "cartagena",
    "san-miguel-de-allende", "san-juan", "nara", "kamakura", "kanazawa",
    "fez", "marrakech", "chefchaouen", "galle", "jaipur", "udaipur",
    "varanasi", "pondicherry", "kochi", "samarkand", "bukhara",
    "willemstad", "bridgetown", "oaxaca", "faro", "rhodes", "corfu",
    "antalya", "macau", "tainan", "jiufen"
}

COFFEE_CULTURE_CITIES = {
    "chiang-mai", "ubud", "hanoi", "dalat", "oaxaca", "san-miguel-de-allende",
    "bruges", "colmar", "lucerne", "luang-prabang", "hoi-an",
    "cameron-highlands", "ipoh", "galle", "pondicherry", "kanazawa",
    "cusco", "cartagena", "cesky-krumlov", "bandung", "ella",
    "antigua-guatemala", "fukuoka", "sapporo"
}

FAMILY_FRIENDLY_CITIES = {
    "queenstown", "rotorua", "nadi", "rarotonga", "lucerne", "interlaken",
    "bruges", "crete", "rhodes", "corfu", "nassau", "punta-cana",
    "san-juan", "antalya", "langkawi", "sapporo", "hakone", "nara",
    "kanazawa", "jeju", "hualien", "lake-bled", "faro", "rovaniemi",
    "bridgetown", "montego-bay", "lake-como"
}

STARTUP_HUB_CITIES = {
    "fukuoka"
}

STUDENT_FRIENDLY_CITIES = {
    "cusco", "antigua-guatemala", "san-sebastian", "oaxaca", "faro"
}


# ── Manual overrides ────────────────────────────────────────────────────────

MANUAL_OVERRIDES = {
    "chiang-mai": {
        "Digital Nomad": 0.95, "Affordable": 0.9, "Foodie": 0.85,
        "Bohemian": 0.8, "Coffee Culture": 0.75, "Walkable": 0.7,
    },
    "ubud": {
        "Bohemian": 0.9, "Quiet & Peaceful": 0.85, "Eco-Conscious": 0.8,
        "Coffee Culture": 0.75, "Outdoorsy": 0.8, "Walkable": 0.65,
    },
    "santorini": {
        "Luxury": 0.9, "Beach Life": 0.85, "Quiet & Peaceful": 0.7,
        "Walkable": 0.8, "Foodie": 0.7,
    },
    "mykonos": {
        "Nightlife": 0.95, "Beach Life": 0.9, "Luxury": 0.85,
        "LGBTQ+ Friendly": 0.8, "Cosmopolitan": 0.7,
    },
    "queenstown": {
        "Outdoorsy": 0.95, "Fast-Paced": 0.7, "Family Friendly": 0.65,
        "Eco-Conscious": 0.7,
    },
    "bora-bora": {
        "Luxury": 0.95, "Beach Life": 0.95, "Quiet & Peaceful": 0.9,
        "Eco-Conscious": 0.7,
    },
    "dubrovnik": {
        "Historic": 0.9, "Beach Life": 0.7, "Walkable": 0.85,
        "Foodie": 0.65, "LGBTQ+ Friendly": 0.5,
    },
    "marrakech": {
        "Foodie": 0.9, "Historic": 0.85, "Arts & Music": 0.8,
        "Walkable": 0.8, "Affordable": 0.7,
    },
    "cusco": {
        "Historic": 0.95, "Outdoorsy": 0.8, "Bohemian": 0.7,
        "Affordable": 0.75, "Coffee Culture": 0.65,
    },
    "hoi-an": {
        "Historic": 0.9, "Foodie": 0.9, "Affordable": 0.85,
        "Walkable": 0.85, "Coffee Culture": 0.7, "Bohemian": 0.65,
    },
    "jaipur": {
        "Historic": 0.95, "Arts & Music": 0.8, "Affordable": 0.8,
        "Walkable": 0.75, "Foodie": 0.75,
    },
    "san-sebastian": {
        "Foodie": 0.95, "Beach Life": 0.8, "Walkable": 0.85,
        "LGBTQ+ Friendly": 0.65, "Cosmopolitan": 0.6,
    },
    "phuket": {
        "Beach Life": 0.9, "Nightlife": 0.85, "Affordable": 0.75,
        "Foodie": 0.7,
    },
    "koh-samui": {
        "Beach Life": 0.9, "Quiet & Peaceful": 0.65, "Luxury": 0.6,
        "Foodie": 0.65,
    },
    "maldives": {
        "Luxury": 0.95, "Beach Life": 0.95, "Quiet & Peaceful": 0.9,
        "Eco-Conscious": 0.6,
    },
    "lake-como": {
        "Luxury": 0.9, "Quiet & Peaceful": 0.8, "Outdoorsy": 0.7,
        "Walkable": 0.65, "Foodie": 0.7,
    },
    "amalfi": {
        "Luxury": 0.8, "Beach Life": 0.75, "Foodie": 0.85,
        "Historic": 0.7, "Walkable": 0.8,
    },
    "positano": {
        "Luxury": 0.85, "Beach Life": 0.7, "Walkable": 0.75,
        "Quiet & Peaceful": 0.65,
    },
    "cinque-terre": {
        "Walkable": 0.85, "Outdoorsy": 0.8, "Foodie": 0.75,
        "Beach Life": 0.65, "Eco-Conscious": 0.6,
    },
    "hallstatt": {
        "Quiet & Peaceful": 0.9, "Outdoorsy": 0.8, "Walkable": 0.8,
        "Historic": 0.7,
    },
    "bruges": {
        "Walkable": 0.9, "Historic": 0.85, "Foodie": 0.8,
        "Coffee Culture": 0.75, "Family Friendly": 0.6,
    },
    "colmar": {
        "Walkable": 0.85, "Foodie": 0.8, "Historic": 0.75,
        "Quiet & Peaceful": 0.7, "Family Friendly": 0.55,
    },
    "luang-prabang": {
        "Quiet & Peaceful": 0.9, "Historic": 0.85, "Affordable": 0.8,
        "Bohemian": 0.7, "Eco-Conscious": 0.65, "Walkable": 0.75,
        "Coffee Culture": 0.6,
    },
    "oaxaca": {
        "Foodie": 0.9, "Arts & Music": 0.85, "Bohemian": 0.8,
        "Affordable": 0.75, "Historic": 0.7, "Coffee Culture": 0.7,
        "Digital Nomad": 0.7,
    },
    "tulum": {
        "Beach Life": 0.9, "Bohemian": 0.85, "Nightlife": 0.7,
        "Eco-Conscious": 0.65, "Digital Nomad": 0.7, "LGBTQ+ Friendly": 0.6,
    },
    "zanzibar": {
        "Beach Life": 0.9, "Historic": 0.75, "Affordable": 0.7,
        "Foodie": 0.7, "Quiet & Peaceful": 0.6,
    },
    "cappadocia": {
        "Outdoorsy": 0.85, "Historic": 0.8, "Quiet & Peaceful": 0.7,
        "Eco-Conscious": 0.6, "Bohemian": 0.6,
    },
    "goa": {
        "Beach Life": 0.9, "Nightlife": 0.8, "Bohemian": 0.8,
        "Affordable": 0.8, "Foodie": 0.7,
    },
    "cartagena": {
        "Historic": 0.85, "Beach Life": 0.7, "Nightlife": 0.75,
        "Foodie": 0.8, "Walkable": 0.8, "Arts & Music": 0.7,
        "LGBTQ+ Friendly": 0.55,
    },
    "siem-reap": {
        "Historic": 0.95, "Affordable": 0.9, "Outdoorsy": 0.6,
        "Foodie": 0.65, "Bohemian": 0.6,
    },
    "bagan": {
        "Historic": 0.95, "Quiet & Peaceful": 0.85, "Outdoorsy": 0.75,
        "Affordable": 0.8, "Eco-Conscious": 0.6,
    },
    "petra": {
        "Historic": 0.95, "Outdoorsy": 0.85, "Quiet & Peaceful": 0.7,
    },
    "wadi-rum": {
        "Outdoorsy": 0.95, "Quiet & Peaceful": 0.9,
        "Eco-Conscious": 0.7, "Affordable": 0.65,
    },
    "varanasi": {
        "Historic": 0.95, "Arts & Music": 0.75, "Affordable": 0.8,
        "Walkable": 0.7,
    },
    "hampi": {
        "Historic": 0.9, "Outdoorsy": 0.7, "Affordable": 0.85,
        "Bohemian": 0.75, "Quiet & Peaceful": 0.8,
    },
    "interlaken": {
        "Outdoorsy": 0.95, "Luxury": 0.65, "Fast-Paced": 0.6,
        "Family Friendly": 0.6, "Eco-Conscious": 0.65,
    },
    "lofoten": {
        "Outdoorsy": 0.95, "Quiet & Peaceful": 0.85, "Eco-Conscious": 0.8,
        "Beach Life": 0.5,
    },
    "tromso": {
        "Outdoorsy": 0.9, "Eco-Conscious": 0.75, "Quiet & Peaceful": 0.7,
        "Coffee Culture": 0.5,
    },
    "rovaniemi": {
        "Outdoorsy": 0.8, "Family Friendly": 0.7, "Quiet & Peaceful": 0.7,
        "Eco-Conscious": 0.6,
    },
    "samarkand": {
        "Historic": 0.95, "Arts & Music": 0.8, "Affordable": 0.75,
        "Walkable": 0.7,
    },
    "bukhara": {
        "Historic": 0.95, "Walkable": 0.8, "Affordable": 0.75,
        "Quiet & Peaceful": 0.65,
    },
    "fez": {
        "Historic": 0.9, "Walkable": 0.85, "Foodie": 0.8,
        "Arts & Music": 0.75, "Affordable": 0.7,
    },
    "essaouira": {
        "Beach Life": 0.75, "Bohemian": 0.8, "Arts & Music": 0.7,
        "Affordable": 0.7, "Quiet & Peaceful": 0.6,
    },
    "chefchaouen": {
        "Walkable": 0.8, "Bohemian": 0.75, "Quiet & Peaceful": 0.7,
        "Affordable": 0.75, "Arts & Music": 0.6,
    },
    "antigua-guatemala": {
        "Historic": 0.85, "Walkable": 0.85, "Affordable": 0.8,
        "Coffee Culture": 0.75, "Bohemian": 0.65,
    },
    "lake-atitlan": {
        "Outdoorsy": 0.85, "Bohemian": 0.8, "Quiet & Peaceful": 0.8,
        "Affordable": 0.8, "Eco-Conscious": 0.7,
    },
    "palawan": {
        "Beach Life": 0.95, "Outdoorsy": 0.85, "Eco-Conscious": 0.8,
        "Quiet & Peaceful": 0.75, "Affordable": 0.7,
    },
    "boracay": {
        "Beach Life": 0.95, "Nightlife": 0.75, "Affordable": 0.7,
    },
    "siargao": {
        "Beach Life": 0.9, "Bohemian": 0.85, "Outdoorsy": 0.8,
        "Quiet & Peaceful": 0.7, "Affordable": 0.75,
    },
    "pai": {
        "Bohemian": 0.9, "Quiet & Peaceful": 0.8, "Affordable": 0.85,
        "Outdoorsy": 0.75, "Coffee Culture": 0.6,
    },
    "koh-lanta": {
        "Beach Life": 0.85, "Quiet & Peaceful": 0.8, "Affordable": 0.75,
        "Digital Nomad": 0.65, "Family Friendly": 0.55,
    },
    "ella": {
        "Outdoorsy": 0.85, "Quiet & Peaceful": 0.8, "Affordable": 0.75,
        "Coffee Culture": 0.7, "Eco-Conscious": 0.65,
    },
    "nara": {
        "Historic": 0.9, "Walkable": 0.85, "Quiet & Peaceful": 0.75,
        "Family Friendly": 0.65, "Eco-Conscious": 0.55,
    },
    "kanazawa": {
        "Historic": 0.85, "Walkable": 0.8, "Foodie": 0.8,
        "Arts & Music": 0.7, "Quiet & Peaceful": 0.65,
    },
    "naoshima": {
        "Arts & Music": 0.95, "Quiet & Peaceful": 0.8, "Walkable": 0.7,
        "Eco-Conscious": 0.65, "Bohemian": 0.7,
    },
    "hakone": {
        "Outdoorsy": 0.8, "Quiet & Peaceful": 0.8, "Luxury": 0.65,
        "Family Friendly": 0.6,
    },
    "kamakura": {
        "Historic": 0.85, "Walkable": 0.8, "Beach Life": 0.55,
        "Quiet & Peaceful": 0.65,
    },
    "takayama": {
        "Historic": 0.8, "Foodie": 0.8, "Quiet & Peaceful": 0.75,
        "Walkable": 0.75, "Coffee Culture": 0.55,
    },
    "sapporo": {
        "Foodie": 0.85, "Outdoorsy": 0.8, "Coffee Culture": 0.65,
        "Family Friendly": 0.6,
    },
    "fukuoka": {
        "Foodie": 0.9, "Startup Hub": 0.55, "Nightlife": 0.65,
        "Cosmopolitan": 0.6, "Walkable": 0.7,
    },
    "jeju": {
        "Outdoorsy": 0.85, "Beach Life": 0.7, "Family Friendly": 0.65,
        "Foodie": 0.65, "Eco-Conscious": 0.6,
    },
    "gyeongju": {
        "Historic": 0.9, "Walkable": 0.75, "Quiet & Peaceful": 0.7,
        "Family Friendly": 0.55,
    },
    "livingstone": {
        "Outdoorsy": 0.9, "Fast-Paced": 0.65, "Eco-Conscious": 0.7,
        "Affordable": 0.65,
    },
    "kotor": {
        "Historic": 0.85, "Walkable": 0.85, "Outdoorsy": 0.7,
        "Beach Life": 0.6, "Quiet & Peaceful": 0.6, "Affordable": 0.65,
    },
    "hvar": {
        "Beach Life": 0.85, "Nightlife": 0.7, "Luxury": 0.65,
        "Walkable": 0.7, "LGBTQ+ Friendly": 0.5,
    },
    "lake-bled": {
        "Outdoorsy": 0.85, "Quiet & Peaceful": 0.8, "Walkable": 0.75,
        "Family Friendly": 0.6, "Eco-Conscious": 0.65,
    },
    "mostar": {
        "Historic": 0.85, "Walkable": 0.8, "Affordable": 0.7,
        "Outdoorsy": 0.55,
    },
    "cesky-krumlov": {
        "Historic": 0.85, "Walkable": 0.85, "Bohemian": 0.65,
        "Quiet & Peaceful": 0.7, "Coffee Culture": 0.55,
    },
    "valletta": {
        "Historic": 0.9, "Walkable": 0.85, "Foodie": 0.7,
        "Beach Life": 0.55, "Cosmopolitan": 0.55,
    },
    "caye-caulker": {
        "Beach Life": 0.9, "Bohemian": 0.85, "Quiet & Peaceful": 0.8,
        "Affordable": 0.7, "Digital Nomad": 0.6, "Eco-Conscious": 0.65,
    },
    "bocas-del-toro": {
        "Beach Life": 0.9, "Bohemian": 0.8, "Nightlife": 0.65,
        "Affordable": 0.7, "Outdoorsy": 0.6,
    },
    "san-juan": {
        "Historic": 0.8, "Beach Life": 0.75, "Nightlife": 0.7,
        "Foodie": 0.7, "Walkable": 0.7, "LGBTQ+ Friendly": 0.6,
    },
    "nassau": {
        "Beach Life": 0.9, "Luxury": 0.65, "Family Friendly": 0.6,
        "Nightlife": 0.55,
    },
    "bridgetown": {
        "Beach Life": 0.85, "Historic": 0.6, "Foodie": 0.65,
        "Family Friendly": 0.6, "Walkable": 0.6, "LGBTQ+ Friendly": 0.5,
    },
    "willemstad": {
        "Walkable": 0.8, "Historic": 0.7, "Beach Life": 0.7,
        "Foodie": 0.6, "LGBTQ+ Friendly": 0.55,
    },
    "montego-bay": {
        "Beach Life": 0.85, "Nightlife": 0.7, "Foodie": 0.65,
        "Arts & Music": 0.7, "Family Friendly": 0.55,
    },
    "punta-cana": {
        "Beach Life": 0.95, "Luxury": 0.65, "Family Friendly": 0.65,
        "Nightlife": 0.6,
    },
    "bariloche": {
        "Outdoorsy": 0.9, "Foodie": 0.7, "Quiet & Peaceful": 0.7,
        "Eco-Conscious": 0.65, "Family Friendly": 0.55,
    },
    "mendoza": {
        "Foodie": 0.85, "Outdoorsy": 0.75, "Quiet & Peaceful": 0.6,
        "Affordable": 0.65,
    },
    "la-paz": {
        "Outdoorsy": 0.8, "Affordable": 0.85, "Historic": 0.65,
        "Bohemian": 0.6, "Fast-Paced": 0.55,
    },
    "sucre": {
        "Historic": 0.8, "Walkable": 0.75, "Affordable": 0.8,
        "Quiet & Peaceful": 0.7,
    },
    "banos": {
        "Outdoorsy": 0.9, "Fast-Paced": 0.65, "Affordable": 0.75,
        "Eco-Conscious": 0.6,
    },
    "sacred-valley": {
        "Outdoorsy": 0.9, "Historic": 0.8, "Quiet & Peaceful": 0.75,
        "Eco-Conscious": 0.7, "Affordable": 0.7, "Bohemian": 0.55,
    },
    "san-miguel-de-allende": {
        "Historic": 0.85, "Arts & Music": 0.85, "Foodie": 0.8,
        "Walkable": 0.8, "Coffee Culture": 0.7, "LGBTQ+ Friendly": 0.55,
        "Digital Nomad": 0.6,
    },
    "playa-del-carmen": {
        "Beach Life": 0.85, "Nightlife": 0.8, "Digital Nomad": 0.7,
        "Foodie": 0.65, "LGBTQ+ Friendly": 0.55,
    },
    "udaipur": {
        "Historic": 0.9, "Luxury": 0.7, "Walkable": 0.75,
        "Quiet & Peaceful": 0.65, "Arts & Music": 0.65, "Affordable": 0.75,
    },
    "pokhara": {
        "Outdoorsy": 0.95, "Quiet & Peaceful": 0.8, "Affordable": 0.8,
        "Bohemian": 0.65, "Eco-Conscious": 0.6,
    },
    "kathmandu": {
        "Historic": 0.85, "Outdoorsy": 0.75, "Affordable": 0.8,
        "Bohemian": 0.65, "Arts & Music": 0.6,
    },
    "galle": {
        "Historic": 0.85, "Walkable": 0.8, "Beach Life": 0.7,
        "Foodie": 0.65, "Coffee Culture": 0.6, "Quiet & Peaceful": 0.6,
    },
    "kandy": {
        "Historic": 0.85, "Outdoorsy": 0.7, "Quiet & Peaceful": 0.65,
        "Affordable": 0.7, "Eco-Conscious": 0.6,
    },
    "colombo": {
        "Foodie": 0.7, "Historic": 0.6, "Cosmopolitan": 0.55,
        "Affordable": 0.7, "Beach Life": 0.5,
    },
    "pondicherry": {
        "Historic": 0.7, "Bohemian": 0.7, "Beach Life": 0.6,
        "Walkable": 0.75, "Affordable": 0.75, "Coffee Culture": 0.6,
    },
    "kochi": {
        "Historic": 0.7, "Foodie": 0.75, "Walkable": 0.7,
        "Arts & Music": 0.6, "Affordable": 0.7,
    },
    "batumi": {
        "Beach Life": 0.7, "Nightlife": 0.65, "Affordable": 0.8,
        "Digital Nomad": 0.65, "Cosmopolitan": 0.5,
    },
    "luxor": {
        "Historic": 0.95, "Outdoorsy": 0.6, "Affordable": 0.8,
        "Quiet & Peaceful": 0.6,
    },
    "aswan": {
        "Historic": 0.85, "Quiet & Peaceful": 0.75, "Affordable": 0.8,
        "Outdoorsy": 0.6,
    },
    "da-nang": {
        "Beach Life": 0.8, "Foodie": 0.75, "Affordable": 0.8,
        "Digital Nomad": 0.75, "Outdoorsy": 0.6,
    },
    "hanoi": {
        "Foodie": 0.9, "Historic": 0.8, "Affordable": 0.8,
        "Coffee Culture": 0.75, "Fast-Paced": 0.7, "Walkable": 0.6,
    },
    "penang": {
        "Foodie": 0.9, "Historic": 0.8, "Affordable": 0.75,
        "Walkable": 0.7, "Arts & Music": 0.65, "Digital Nomad": 0.65,
    },
    "langkawi": {
        "Beach Life": 0.85, "Quiet & Peaceful": 0.7, "Family Friendly": 0.6,
        "Outdoorsy": 0.65, "Affordable": 0.65,
    },
    "krabi": {
        "Beach Life": 0.9, "Outdoorsy": 0.85, "Affordable": 0.75,
        "Quiet & Peaceful": 0.6,
    },
    "seminyak": {
        "Beach Life": 0.85, "Nightlife": 0.8, "Luxury": 0.65,
        "Foodie": 0.7, "LGBTQ+ Friendly": 0.55, "Digital Nomad": 0.6,
    },
    "yogyakarta": {
        "Historic": 0.85, "Arts & Music": 0.8, "Affordable": 0.8,
        "Foodie": 0.7, "Bohemian": 0.65,
    },
    "bandung": {
        "Foodie": 0.7, "Coffee Culture": 0.7, "Affordable": 0.75,
        "Outdoorsy": 0.6, "Arts & Music": 0.55,
    },
    "cebu": {
        "Beach Life": 0.75, "Affordable": 0.7, "Foodie": 0.6,
        "Historic": 0.55, "Digital Nomad": 0.6,
    },
    "lombok": {
        "Beach Life": 0.85, "Outdoorsy": 0.8, "Quiet & Peaceful": 0.7,
        "Affordable": 0.7, "Eco-Conscious": 0.6,
    },
    "flores": {
        "Outdoorsy": 0.9, "Eco-Conscious": 0.8, "Quiet & Peaceful": 0.75,
        "Affordable": 0.7, "Beach Life": 0.6,
    },
    "crete": {
        "Beach Life": 0.8, "Historic": 0.8, "Foodie": 0.8,
        "Outdoorsy": 0.7, "Family Friendly": 0.6,
    },
    "rhodes": {
        "Historic": 0.85, "Beach Life": 0.8, "Walkable": 0.7,
        "Family Friendly": 0.6, "Foodie": 0.6,
    },
    "corfu": {
        "Beach Life": 0.8, "Historic": 0.65, "Quiet & Peaceful": 0.6,
        "Family Friendly": 0.6, "Outdoorsy": 0.6, "Walkable": 0.55,
    },
    "antalya": {
        "Beach Life": 0.85, "Historic": 0.7, "Family Friendly": 0.6,
        "Affordable": 0.65, "Walkable": 0.6,
    },
    "bodrum": {
        "Beach Life": 0.8, "Nightlife": 0.75, "Luxury": 0.65,
        "Historic": 0.6, "Foodie": 0.6,
    },
    "faro": {
        "Beach Life": 0.75, "Walkable": 0.7, "Affordable": 0.65,
        "Quiet & Peaceful": 0.6, "Family Friendly": 0.55,
        "Student Friendly": 0.5,
    },
    "sintra": {
        "Historic": 0.85, "Walkable": 0.8, "Outdoorsy": 0.65,
        "Quiet & Peaceful": 0.7, "Family Friendly": 0.55,
    },
    "lucerne": {
        "Walkable": 0.85, "Outdoorsy": 0.75, "Family Friendly": 0.65,
        "Historic": 0.65, "Coffee Culture": 0.6, "Luxury": 0.55,
    },
    "sibenik": {
        "Historic": 0.8, "Beach Life": 0.7, "Walkable": 0.7,
        "Quiet & Peaceful": 0.6, "Affordable": 0.6,
    },
    "tangier": {
        "Historic": 0.75, "Arts & Music": 0.7, "Bohemian": 0.65,
        "Affordable": 0.7, "Cosmopolitan": 0.55,
    },
    "macau": {
        "Luxury": 0.8, "Foodie": 0.75, "Historic": 0.7,
        "Walkable": 0.7, "Nightlife": 0.65,
    },
    "guilin": {
        "Outdoorsy": 0.9, "Quiet & Peaceful": 0.7, "Affordable": 0.7,
        "Eco-Conscious": 0.65,
    },
    "lijiang": {
        "Historic": 0.8, "Walkable": 0.7, "Outdoorsy": 0.7,
        "Quiet & Peaceful": 0.6, "Bohemian": 0.55, "Affordable": 0.65,
    },
    "kunming": {
        "Outdoorsy": 0.7, "Affordable": 0.7, "Quiet & Peaceful": 0.55,
        "Foodie": 0.6,
    },
    "xiamen": {
        "Walkable": 0.75, "Beach Life": 0.6, "Foodie": 0.65,
        "Historic": 0.6, "Affordable": 0.6,
    },
    "dali": {
        "Bohemian": 0.8, "Outdoorsy": 0.7, "Quiet & Peaceful": 0.75,
        "Affordable": 0.7, "Arts & Music": 0.6,
    },
    "zhangjiajie": {
        "Outdoorsy": 0.95, "Eco-Conscious": 0.7, "Quiet & Peaceful": 0.65,
        "Affordable": 0.65,
    },
    "nha-trang": {
        "Beach Life": 0.85, "Affordable": 0.8, "Nightlife": 0.6,
        "Outdoorsy": 0.6,
    },
    "dalat": {
        "Coffee Culture": 0.8, "Outdoorsy": 0.75, "Quiet & Peaceful": 0.7,
        "Affordable": 0.8, "Bohemian": 0.6, "Eco-Conscious": 0.55,
        "Digital Nomad": 0.6,
    },
    "malacca": {
        "Historic": 0.85, "Foodie": 0.8, "Walkable": 0.75,
        "Affordable": 0.7,
    },
    "ipoh": {
        "Foodie": 0.8, "Affordable": 0.75, "Historic": 0.65,
        "Coffee Culture": 0.7, "Quiet & Peaceful": 0.6,
    },
    "cameron-highlands": {
        "Outdoorsy": 0.8, "Quiet & Peaceful": 0.75, "Coffee Culture": 0.7,
        "Eco-Conscious": 0.65, "Affordable": 0.65,
    },
    "kota-kinabalu": {
        "Outdoorsy": 0.85, "Eco-Conscious": 0.75, "Beach Life": 0.6,
        "Affordable": 0.65, "Foodie": 0.6,
    },
    "vientiane": {
        "Quiet & Peaceful": 0.75, "Affordable": 0.8, "Historic": 0.6,
        "Walkable": 0.6, "Coffee Culture": 0.55,
    },
    "phnom-penh": {
        "Historic": 0.75, "Affordable": 0.85, "Foodie": 0.7,
        "Fast-Paced": 0.6, "Nightlife": 0.55,
    },
    "battambang": {
        "Arts & Music": 0.7, "Affordable": 0.8, "Quiet & Peaceful": 0.7,
        "Historic": 0.6, "Bohemian": 0.6,
    },
    "chiang-rai": {
        "Arts & Music": 0.75, "Quiet & Peaceful": 0.7, "Affordable": 0.8,
        "Outdoorsy": 0.65, "Historic": 0.6,
    },
    "okinawa": {
        "Beach Life": 0.85, "Outdoorsy": 0.7, "Family Friendly": 0.6,
        "Historic": 0.6, "Foodie": 0.6,
    },
    "hiroshima": {
        "Historic": 0.9, "Foodie": 0.7, "Walkable": 0.7,
        "Family Friendly": 0.55,
    },
    "beppu": {
        "Outdoorsy": 0.75, "Quiet & Peaceful": 0.7, "Foodie": 0.6,
        "Eco-Conscious": 0.55,
    },
    "kaohsiung": {
        "Foodie": 0.75, "Arts & Music": 0.7, "Walkable": 0.65,
        "Affordable": 0.6, "Beach Life": 0.5,
    },
    "tainan": {
        "Historic": 0.85, "Foodie": 0.85, "Walkable": 0.75,
        "Affordable": 0.65,
    },
    "hualien": {
        "Outdoorsy": 0.9, "Eco-Conscious": 0.7, "Quiet & Peaceful": 0.7,
        "Family Friendly": 0.55,
    },
    "jiufen": {
        "Historic": 0.7, "Walkable": 0.75, "Foodie": 0.65,
        "Quiet & Peaceful": 0.6, "Coffee Culture": 0.55,
    },
    "wanaka": {
        "Outdoorsy": 0.9, "Quiet & Peaceful": 0.8, "Eco-Conscious": 0.7,
        "Family Friendly": 0.55,
    },
    "rotorua": {
        "Outdoorsy": 0.85, "Eco-Conscious": 0.7, "Family Friendly": 0.65,
        "Historic": 0.55,
    },
    "nadi": {
        "Beach Life": 0.85, "Family Friendly": 0.65, "Eco-Conscious": 0.6,
        "Quiet & Peaceful": 0.6,
    },
    "moorea": {
        "Beach Life": 0.9, "Quiet & Peaceful": 0.85, "Luxury": 0.75,
        "Eco-Conscious": 0.7, "Outdoorsy": 0.65,
    },
    "rarotonga": {
        "Beach Life": 0.85, "Quiet & Peaceful": 0.8, "Eco-Conscious": 0.7,
        "Family Friendly": 0.6, "Affordable": 0.5,
    },
    "sapa": {
        "Outdoorsy": 0.9, "Quiet & Peaceful": 0.75, "Affordable": 0.8,
        "Eco-Conscious": 0.65, "Historic": 0.55,
    },
    "ninh-binh": {
        "Outdoorsy": 0.85, "Quiet & Peaceful": 0.8, "Affordable": 0.8,
        "Eco-Conscious": 0.65, "Historic": 0.55,
    },
    "pakse": {
        "Quiet & Peaceful": 0.7, "Affordable": 0.8, "Outdoorsy": 0.65,
        "Eco-Conscious": 0.6,
    },
    "savannakhet": {
        "Historic": 0.6, "Quiet & Peaceful": 0.75, "Affordable": 0.8,
    },
    "luang-namtha": {
        "Outdoorsy": 0.85, "Quiet & Peaceful": 0.8, "Affordable": 0.8,
        "Eco-Conscious": 0.75,
    },
    "muang-ngoi": {
        "Quiet & Peaceful": 0.9, "Outdoorsy": 0.8, "Affordable": 0.8,
        "Eco-Conscious": 0.7,
    },
    "salalah": {
        "Outdoorsy": 0.7, "Beach Life": 0.65, "Quiet & Peaceful": 0.7,
        "Historic": 0.55,
    },
    "aqaba": {
        "Beach Life": 0.75, "Outdoorsy": 0.7, "Affordable": 0.6,
        "Historic": 0.5,
    },
    "nagano": {
        "Outdoorsy": 0.85, "Quiet & Peaceful": 0.7, "Historic": 0.6,
        "Family Friendly": 0.55, "Eco-Conscious": 0.55,
    },
    "matsumoto": {
        "Historic": 0.8, "Walkable": 0.75, "Quiet & Peaceful": 0.7,
        "Arts & Music": 0.6, "Outdoorsy": 0.65,
    },
}


def has_keyword(text, keywords):
    """Check if any keyword appears in text (case-insensitive)."""
    text_lower = text.lower()
    return any(kw.lower() in text_lower for kw in keywords)


def keyword_count(text, keywords):
    """Count how many keywords appear in text."""
    text_lower = text.lower()
    return sum(1 for kw in keywords if kw.lower() in text_lower)


def clamp(val, lo=0.3, hi=1.0):
    return max(lo, min(hi, round(val, 2)))


def assign_vibes(city):
    """Assign vibe tags for a single city based on rules."""
    cid = city["id"]
    name = city["name"]
    country = city["country"]
    continent = city["continent"]
    summary = city.get("summary", "")
    scores = city.get("scores", {})
    pop = city.get("population", 0)

    # Extract relevant scores
    cost_of_living = scores.get("Cost of Living", 5)
    outdoors = scores.get("Outdoors", 5)
    leisure_culture = scores.get("Leisure & Culture", 5)
    tolerance = scores.get("Tolerance", 5)
    safety = scores.get("Safety", 5)
    internet = scores.get("Internet Access", 5)
    startups = scores.get("Startups", 3)
    env_quality = scores.get("Environmental Quality", 5)
    education = scores.get("Education", 5)

    vibes = {}

    # ── Beach Life ─────────────────────────────────────────────────
    if has_keyword(summary, COASTAL_KEYWORDS):
        count = keyword_count(summary, COASTAL_KEYWORDS)
        strength = clamp(0.55 + count * 0.08, 0.5, 0.9)
        vibes["Beach Life"] = strength

    # ── Outdoorsy ──────────────────────────────────────────────────
    if outdoors >= 6.5 or has_keyword(summary, NATURE_KEYWORDS):
        base = 0.5 + (outdoors - 5) * 0.06
        if has_keyword(summary, NATURE_KEYWORDS):
            base += 0.1
        vibes["Outdoorsy"] = clamp(base, 0.5, 0.9)

    # ── Foodie ─────────────────────────────────────────────────────
    if has_keyword(summary, FOOD_KEYWORDS) or leisure_culture >= 7.5:
        base = 0.5
        if has_keyword(summary, FOOD_KEYWORDS):
            base += 0.15 + keyword_count(summary, FOOD_KEYWORDS) * 0.05
        if leisure_culture >= 7.5:
            base += 0.1
        vibes["Foodie"] = clamp(base, 0.5, 0.9)

    # ── Historic ───────────────────────────────────────────────────
    if has_keyword(summary, HISTORIC_KEYWORDS):
        count = keyword_count(summary, HISTORIC_KEYWORDS)
        strength = clamp(0.5 + count * 0.08, 0.5, 0.9)
        vibes["Historic"] = strength

    # ── Walkable ───────────────────────────────────────────────────
    if cid in WALKABLE_CITIES:
        vibes["Walkable"] = clamp(0.7, 0.5, 0.85)
    elif pop < 100000 and has_keyword(summary, ["walkable", "pedestrian", "stroll", "wander", "cobblestone", "old town", "car-free"]):
        vibes["Walkable"] = clamp(0.65, 0.5, 0.8)

    # ── Bohemian ───────────────────────────────────────────────────
    if has_keyword(summary, BOHEMIAN_KEYWORDS):
        count = keyword_count(summary, BOHEMIAN_KEYWORDS)
        vibes["Bohemian"] = clamp(0.5 + count * 0.1, 0.5, 0.85)

    # ── Affordable ─────────────────────────────────────────────────
    if cost_of_living >= 7.5 or country in AFFORDABLE_COUNTRIES:
        base = 0.4 + (cost_of_living - 5) * 0.08
        if country in SE_ASIAN_COUNTRIES:
            base += 0.1
        elif country in SOUTH_ASIAN_COUNTRIES:
            base += 0.1
        vibes["Affordable"] = clamp(base, 0.5, 0.9)

    # ── Digital Nomad ──────────────────────────────────────────────
    if cid in DIGITAL_NOMAD_CITIES:
        base = 0.6
        if internet >= 6.5:
            base += 0.1
        if cost_of_living >= 7.5:
            base += 0.1
        vibes["Digital Nomad"] = clamp(base, 0.55, 0.85)

    # ── Nightlife ──────────────────────────────────────────────────
    if has_keyword(summary, NIGHTLIFE_KEYWORDS):
        count = keyword_count(summary, NIGHTLIFE_KEYWORDS)
        vibes["Nightlife"] = clamp(0.5 + count * 0.1, 0.5, 0.85)

    # ── Quiet & Peaceful ──────────────────────────────────────────
    if pop < 80000 or has_keyword(summary, ["serene", "tranquil", "peaceful", "sleepy", "quiet", "relaxed", "retreat", "misty"]):
        base = 0.5
        if pop < 30000:
            base += 0.15
        elif pop < 80000:
            base += 0.08
        if has_keyword(summary, ["serene", "tranquil", "peaceful", "quiet", "retreat"]):
            base += 0.1
        vibes["Quiet & Peaceful"] = clamp(base, 0.5, 0.85)

    # ── Luxury ─────────────────────────────────────────────────────
    if has_keyword(summary, LUXURY_KEYWORDS):
        count = keyword_count(summary, LUXURY_KEYWORDS)
        vibes["Luxury"] = clamp(0.55 + count * 0.1, 0.5, 0.85)

    # ── Coffee Culture ─────────────────────────────────────────────
    if cid in COFFEE_CULTURE_CITIES or has_keyword(summary, COFFEE_KEYWORDS):
        base = 0.55
        if has_keyword(summary, COFFEE_KEYWORDS):
            base += 0.1
        if cid in COFFEE_CULTURE_CITIES:
            base += 0.1
        vibes["Coffee Culture"] = clamp(base, 0.5, 0.8)

    # ── Eco-Conscious ──────────────────────────────────────────────
    if has_keyword(summary, ECO_KEYWORDS) or env_quality >= 7.5:
        base = 0.5
        if has_keyword(summary, ECO_KEYWORDS):
            base += 0.15
        if env_quality >= 7.5:
            base += 0.1
        vibes["Eco-Conscious"] = clamp(base, 0.5, 0.85)

    # ── Arts & Music ───────────────────────────────────────────────
    if has_keyword(summary, ART_MUSIC_KEYWORDS):
        count = keyword_count(summary, ART_MUSIC_KEYWORDS)
        vibes["Arts & Music"] = clamp(0.45 + count * 0.1, 0.5, 0.85)

    # ── Cosmopolitan ───────────────────────────────────────────────
    if pop > 500000 and tolerance >= 6.5 and leisure_culture >= 7:
        base = 0.5 + (tolerance - 6) * 0.05
        vibes["Cosmopolitan"] = clamp(base, 0.5, 0.8)

    # ── Family Friendly ────────────────────────────────────────────
    if cid in FAMILY_FRIENDLY_CITIES:
        base = 0.55
        if safety >= 7:
            base += 0.1
        vibes["Family Friendly"] = clamp(base, 0.4, 0.7)

    # ── LGBTQ+ Friendly ───────────────────────────────────────────
    if cid in LGBTQ_FRIENDLY_CITIES or tolerance >= 8:
        base = 0.5
        if tolerance >= 8:
            base += 0.1
        vibes["LGBTQ+ Friendly"] = clamp(base, 0.4, 0.8)

    # ── Fast-Paced ─────────────────────────────────────────────────
    if pop > 1000000 and has_keyword(summary, ["bustling", "buzzing", "vibrant", "chaotic", "rapidly", "fast", "modern"]):
        vibes["Fast-Paced"] = clamp(0.55, 0.5, 0.75)

    # ── Startup Hub ────────────────────────────────────────────────
    if cid in STARTUP_HUB_CITIES:
        vibes["Startup Hub"] = clamp(0.5, 0.4, 0.6)

    # ── Student Friendly ───────────────────────────────────────────
    if cid in STUDENT_FRIENDLY_CITIES:
        vibes["Student Friendly"] = clamp(0.5, 0.4, 0.6)

    # ── Apply manual overrides (these take priority) ───────────────
    if cid in MANUAL_OVERRIDES:
        for vibe_name, strength in MANUAL_OVERRIDES[cid].items():
            vibes[vibe_name] = clamp(strength)

    # ── Ensure each city has at least 5 vibes ──────────────────────
    if len(vibes) < 5:
        if "Historic" not in vibes and has_keyword(summary, ["old", "traditional", "culture", "heritage"]):
            vibes["Historic"] = 0.5
        if "Quiet & Peaceful" not in vibes and pop < 200000:
            vibes["Quiet & Peaceful"] = 0.5
        if "Affordable" not in vibes and country in AFFORDABLE_COUNTRIES:
            vibes["Affordable"] = 0.55
        if "Outdoorsy" not in vibes and outdoors >= 5.5:
            vibes["Outdoorsy"] = 0.5
        if "Walkable" not in vibes and pop < 100000:
            vibes["Walkable"] = 0.5

    # ── Cap at 10 vibes ────────────────────────────────────────────
    if len(vibes) > 10:
        sorted_vibes = sorted(vibes.items(), key=lambda x: -x[1])
        vibes = dict(sorted_vibes[:10])

    return vibes


def run_query(sql):
    """Execute SQL via Supabase Management API."""
    resp = requests.post(SUPABASE_URL, headers=HEADERS, json={"query": sql})
    if resp.status_code != 201:
        print(f"  ERROR {resp.status_code}: {resp.text[:500]}")
        return None
    return resp.json()


def main():
    # Load cities
    with open("/Users/burke/Documents/TeleportMe/supabase/travel_cities_enriched.json") as f:
        cities = json.load(f)

    print(f"Loaded {len(cities)} travel cities\n")

    # Verify cities exist in DB (city_id is the text slug in cities.id)
    print("Verifying cities exist in Supabase...")
    result = run_query("SELECT id FROM cities ORDER BY id;")
    if not result:
        print("Failed to fetch cities!")
        return

    db_city_ids = {row["id"] for row in result}
    print(f"  Found {len(db_city_ids)} total cities in DB\n")

    # Match and assign vibes
    all_rows = []
    city_vibe_counts = {}
    vibe_city_counts = {}
    unmatched = []

    for city in cities:
        cid = city["id"]
        if cid not in db_city_ids:
            unmatched.append(cid)
            continue

        vibes = assign_vibes(city)
        city_vibe_counts[cid] = len(vibes)

        for vibe_name, strength in vibes.items():
            vibe_uuid = VIBES[vibe_name]
            all_rows.append((cid, vibe_uuid, strength))
            vibe_city_counts[vibe_name] = vibe_city_counts.get(vibe_name, 0) + 1

    if unmatched:
        print(f"WARNING: {len(unmatched)} cities not found in DB: {unmatched}")

    print(f"Total city-vibe assignments: {len(all_rows)}")
    print(f"Cities with vibes: {len(city_vibe_counts)}")
    avg_vibes = sum(city_vibe_counts.values()) / max(len(city_vibe_counts), 1)
    print(f"Average vibes per city: {avg_vibes:.1f}")
    min_vibes = min(city_vibe_counts.values()) if city_vibe_counts else 0
    max_vibes = max(city_vibe_counts.values()) if city_vibe_counts else 0
    print(f"Min vibes: {min_vibes}, Max vibes: {max_vibes}\n")

    # Show distribution by vibe tag
    print("Vibe tag distribution:")
    for vibe_name in sorted(vibe_city_counts.keys(), key=lambda v: -vibe_city_counts[v]):
        print(f"  {vibe_name:20s}: {vibe_city_counts[vibe_name]:3d} cities")
    print()

    # Show cities with fewest vibes
    fewest = sorted(city_vibe_counts.items(), key=lambda x: x[1])[:5]
    print("Cities with fewest vibes:")
    for cid, count in fewest:
        print(f"  {cid}: {count}")
    print()

    # Upload in batches
    BATCH_SIZE = 100
    total_batches = (len(all_rows) + BATCH_SIZE - 1) // BATCH_SIZE
    print(f"Uploading {len(all_rows)} rows in {total_batches} batches...")

    for i in range(0, len(all_rows), BATCH_SIZE):
        batch = all_rows[i:i + BATCH_SIZE]
        values = ", ".join(
            f"('{city_id}', '{vibe_uuid}'::uuid, {strength})"
            for city_id, vibe_uuid, strength in batch
        )
        sql = f"""
            INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength)
            VALUES {values}
            ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;
        """
        batch_num = i // BATCH_SIZE + 1
        result = run_query(sql)
        if result is not None:
            print(f"  Batch {batch_num}/{total_batches}: {len(batch)} rows OK")
        else:
            print(f"  Batch {batch_num}/{total_batches}: FAILED")
        time.sleep(0.3)

    print("\n--- Verification ---")

    # Verify total count
    result = run_query("SELECT COUNT(*) as cnt FROM city_vibe_tags;")
    if result:
        print(f"Total city_vibe_tags rows: {result[0]['cnt']}")

    # Verify distinct cities
    result = run_query("SELECT COUNT(DISTINCT city_id) as cnt FROM city_vibe_tags;")
    if result:
        print(f"Distinct cities with vibes: {result[0]['cnt']}")

    # Verify distinct vibes used
    result = run_query("SELECT COUNT(DISTINCT vibe_tag_id) as cnt FROM city_vibe_tags;")
    if result:
        print(f"Distinct vibe tags used: {result[0]['cnt']}")

    # Average vibes per city
    result = run_query("""
        SELECT ROUND(AVG(cnt)::numeric, 1) as avg_vibes
        FROM (SELECT city_id, COUNT(*) as cnt FROM city_vibe_tags GROUP BY city_id) sub;
    """)
    if result:
        print(f"Average vibes per city: {result[0]['avg_vibes']}")

    print("\n--- Spot checks ---")

    # Spot check specific cities
    spot_checks = [
        "chiang-mai", "bora-bora", "mykonos", "cusco", "marrakech",
        "santorini", "oaxaca", "dubrovnik", "naoshima", "palawan"
    ]
    for city_id in spot_checks:
        result = run_query(f"""
            SELECT vt.name, cvt.strength
            FROM city_vibe_tags cvt
            JOIN vibe_tags vt ON vt.id = cvt.vibe_tag_id
            WHERE cvt.city_id = '{city_id}'
            ORDER BY cvt.strength DESC;
        """)
        if result:
            tags = ", ".join(f"{r['name']} ({r['strength']})" for r in result)
            print(f"  {city_id}: {tags}")

    print("\nDone!")


if __name__ == "__main__":
    main()
