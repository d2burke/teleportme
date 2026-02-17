#!/usr/bin/env python3
"""
Seed vibe tag mappings for 206 cities in Supabase.
Reads city data from curated_cities_data.json and assigns 5-10 vibe tags
per city based on score heuristics and manual overrides.
"""

import json
import math
import requests
import time

# ── Supabase Management API ──────────────────────────────────────────
API_URL = "https://api.supabase.com/v1/projects/fpdkmurgoqjplbbxlpkl/database/query"
API_KEY = "sbp_6ae0c0d7893b10a48a85081fe71faa38250280d2"
HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0",
}

# ── Vibe Tag UUIDs ───────────────────────────────────────────────────
VIBES = {
    # LIFESTYLE
    "walkable":        "a1000000-0000-0000-0000-000000000001",
    "nightlife":       "a1000000-0000-0000-0000-000000000002",
    "foodie":          "a1000000-0000-0000-0000-000000000003",
    "beach_life":      "a1000000-0000-0000-0000-000000000004",
    "outdoorsy":       "a1000000-0000-0000-0000-000000000005",
    "coffee_culture":  "a1000000-0000-0000-0000-000000000006",
    "luxury":          "a1000000-0000-0000-0000-000000000007",
    # CULTURE
    "arts_music":      "a2000000-0000-0000-0000-000000000001",
    "historic":        "a2000000-0000-0000-0000-000000000002",
    "cosmopolitan":    "a2000000-0000-0000-0000-000000000003",
    "bohemian":        "a2000000-0000-0000-0000-000000000004",
    # PACE
    "fast_paced":      "a3000000-0000-0000-0000-000000000001",
    "quiet_peaceful":  "a3000000-0000-0000-0000-000000000002",
    # VALUES
    "lgbtq_friendly":  "a4000000-0000-0000-0000-000000000001",
    "family_friendly": "a4000000-0000-0000-0000-000000000002",
    "eco_conscious":   "a4000000-0000-0000-0000-000000000003",
    # ENVIRONMENT
    "startup_hub":     "a5000000-0000-0000-0000-000000000001",
    "digital_nomad":   "a5000000-0000-0000-0000-000000000002",
    "student_friendly":"a5000000-0000-0000-0000-000000000003",
    "affordable":      "a5000000-0000-0000-0000-000000000004",
}

# ── Coastal / warm-climate cities (for Beach Life) ───────────────────
COASTAL_WARM = {
    "honolulu", "san-diego", "long-beach", "anaheim", "jacksonville",
    "tampa", "st-petersburg", "virginia-beach", "orlando", "miami",
    "gold-coast", "brisbane", "perth", "adelaide", "newcastle",
    "rio-de-janeiro", "salvador", "recife", "fortaleza",
    "barcelona", "valencia", "malaga", "seville",
    "naples", "palermo", "genoa",
    "athens", "varna",
    "lisbon", "porto",
    "marseille", "montpellier",
    "tel-aviv", "jeddah", "muscat", "doha", "abu-dhabi", "dubai",
    "mumbai", "chennai", "manila", "ho-chi-minh-city", "jakarta",
    "dar-es-salaam", "accra", "dakar", "lagos", "casablanca", "algiers", "tunis",
    "beirut", "istanbul",
    "san-jose-costa-rica", "panama-city", "guayaquil",
    "valparaiso", "montevideo", "lima",
    "guadalajara", "cali",  # not coastal but warm
    "mexico-city",  # not coastal
}

# ── Known nightlife cities ───────────────────────────────────────────
NIGHTLIFE_CITIES = {
    "new-orleans", "las-vegas", "miami", "atlanta", "houston",
    "dallas", "philadelphia", "oakland", "detroit", "memphis",
    "rio-de-janeiro", "salvador", "recife",
    "barcelona", "madrid", "seville", "valencia", "malaga",
    "berlin", "hamburg", "amsterdam", "london", "manchester", "glasgow",
    "paris", "lyon", "marseille",
    "rome", "milan", "naples",
    "budapest", "prague", "warsaw", "krakow",
    "athens", "belgrade", "bucharest", "sofia", "tbilisi",
    "bangkok", "tokyo", "seoul", "taipei", "singapore",
    "tel-aviv", "beirut", "istanbul",
    "buenos-aires", "bogota", "medellin", "mexico-city",
    "lagos", "johannesburg", "cairo",
    "ho-chi-minh-city", "manila",
    "melbourne", "sydney",
    "montevideo", "lima",
    "long-beach", "san-diego", "honolulu",
    "tampa", "orlando",
}

# ── Known foodie cities ──────────────────────────────────────────────
FOODIE_CITIES = {
    "new-orleans", "houston", "san-diego", "san-jose",
    "philadelphia", "oakland", "portland", "san-francisco",
    "tokyo", "osaka", "seoul", "busan", "taipei", "taichung",
    "bangkok", "singapore", "ho-chi-minh-city", "hanoi",
    "paris", "lyon", "marseille", "montpellier", "nantes",
    "rome", "milan", "naples", "bologna", "genoa", "turin", "palermo",
    "barcelona", "madrid", "seville", "valencia",
    "istanbul", "beirut",
    "melbourne", "sydney",
    "mexico-city", "guadalajara", "puebla", "lima",
    "rio-de-janeiro", "salvador",
    "buenos-aires",
    "london", "amsterdam",
    "mumbai", "delhi", "chennai",
    "casablanca", "tunis",
    "athens", "porto",
    "brussels", "antwerp",
}

# ── Known coffee culture cities ──────────────────────────────────────
COFFEE_CITIES = {
    "melbourne", "sydney", "adelaide", "brisbane", "hobart",
    "portland", "seattle", "san-francisco", "oakland",
    "vienna", "graz",
    "stockholm", "gothenburg", "malmo", "oslo", "helsinki", "copenhagen",
    "amsterdam", "rotterdam", "the-hague",
    "paris", "lyon", "nantes",
    "rome", "milan", "turin", "bologna", "naples",
    "buenos-aires", "bogota", "medellin",
    "istanbul", "tbilisi",
    "addis-ababa",
    "berlin", "hamburg", "munich", "leipzig", "dresden",
    "budapest", "prague", "warsaw", "krakow",
    "london", "manchester", "glasgow", "birmingham",
    "lisbon", "porto",
    "taipei", "tokyo", "seoul",
    "curitiba", "porto-alegre",
    "vilnius", "riga",
    "lviv",
}

# ── Known historic cities ───────────────────────────────────────────
HISTORIC_CITIES = {
    "rome", "naples", "palermo", "genoa", "turin", "bologna",
    "athens", "istanbul", "cairo", "tunis", "algiers",
    "paris", "lyon", "marseille",
    "london", "birmingham", "glasgow",
    "madrid", "seville", "barcelona", "valencia", "zaragoza",
    "prague", "budapest", "vienna", "graz",
    "krakow", "warsaw",
    "lisbon", "porto",
    "brussels", "antwerp",
    "amsterdam", "the-hague", "rotterdam",
    "berlin", "dresden", "nuremberg", "hamburg",
    "moscow", "saint-petersburg",
    "kyiv", "lviv",
    "beijing", "shanghai",
    "delhi", "kolkata", "mumbai", "hyderabad",
    "tokyo", "osaka",
    "bangkok",
    "jerusalem", "tehran", "baghdad", "amman", "beirut",
    "lima", "mexico-city", "puebla", "quito", "bogota",
    "havana",
    "casablanca", "dakar",
    "tbilisi", "baku",
    "bucharest", "sofia", "plovdiv", "belgrade",
    "riga", "vilnius", "kaunas",
    "tashkent",
    "philadelphia", "washington", "baltimore", "richmond",
    "quebec-city", "ottawa",
    "salvador", "rio-de-janeiro",
    "valparaiso",
    "skopje", "tirana",
}

# ── Known bohemian/creative cities ───────────────────────────────────
BOHEMIAN_CITIES = {
    "berlin", "leipzig", "dresden",
    "amsterdam",
    "portland", "oakland", "austin",
    "melbourne", "hobart",
    "lisbon", "porto",
    "budapest", "prague",
    "tbilisi",
    "buenos-aires",
    "barcelona",
    "montpellier", "lyon",
    "brighton",
    "new-orleans",
    "krakow", "wrocław",
    "vilnius",
    "lviv",
    "bologna", "turin",
    "athens",
    "belgrade",
    "valparaiso",
    "medellin",
    "mexico-city", "guadalajara",
    "salvador", "recife",
    "accra", "dakar",
    "varna",
    "tirana",
    "malaga",
    "manchester", "glasgow",
}

# ── Known digital nomad destinations ─────────────────────────────────
NOMAD_CITIES = {
    "lisbon", "porto",
    "barcelona", "valencia", "malaga",
    "tbilisi",
    "budapest", "prague",
    "berlin",
    "bangkok", "chiang-mai",
    "ho-chi-minh-city",
    "bali",  # not in list but just in case
    "medellin", "bogota",
    "mexico-city", "guadalajara", "puebla",
    "buenos-aires",
    "tirana",
    "sofia", "plovdiv", "varna",
    "bucharest",
    "belgrade",
    "krakow", "wrocław",
    "lima",
    "kuala-lumpur",
    "manila",
    "tallinn",
    "vilnius", "kaunas",
    "lviv",
    "tashkent",
    "addis-ababa",
    "dar-es-salaam",
    "accra",
    "dakar",
    "rio-de-janeiro",
    "curitiba",
    "austin",
    "san-jose-costa-rica",
    "panama-city",
    "montevideo",
}

# ── Known luxury destinations ────────────────────────────────────────
LUXURY_CITIES = {
    "monaco", "dubai", "abu-dhabi", "doha", "riyadh", "jeddah",
    "singapore", "hong-kong", "tokyo",
    "paris", "london", "milan", "rome",
    "zurich", "geneva",
    "new-york", "san-francisco", "los-angeles",
    "sydney", "melbourne",
    "oslo", "stockholm", "copenhagen",
    "honolulu",
    "muscat",
    "luxembourg-city",
    "amsterdam",
    "vienna", "graz",
}

# ── Manual overrides: city_id -> list of (vibe_key, strength) ────────
MANUAL_OVERRIDES = {
    "rome": [("historic", 0.95), ("foodie", 0.9), ("arts_music", 0.9), ("cosmopolitan", 0.8)],
    "paris": [("historic", 0.9), ("foodie", 0.95), ("arts_music", 0.95), ("cosmopolitan", 0.9), ("luxury", 0.85), ("coffee_culture", 0.8)],
    "new-orleans": [("nightlife", 0.95), ("foodie", 0.95), ("arts_music", 0.9), ("bohemian", 0.8)],
    "berlin": [("nightlife", 0.9), ("arts_music", 0.9), ("bohemian", 0.9), ("lgbtq_friendly", 0.9), ("startup_hub", 0.7)],
    "tokyo": [("foodie", 0.95), ("fast_paced", 0.9), ("cosmopolitan", 0.9), ("walkable", 0.85)],
    "amsterdam": [("walkable", 0.9), ("lgbtq_friendly", 0.9), ("bohemian", 0.8), ("eco_conscious", 0.8), ("coffee_culture", 0.8)],
    "barcelona": [("beach_life", 0.85), ("foodie", 0.85), ("nightlife", 0.85), ("walkable", 0.8), ("arts_music", 0.85)],
    "rio-de-janeiro": [("beach_life", 0.95), ("nightlife", 0.9), ("outdoorsy", 0.8), ("arts_music", 0.8)],
    "istanbul": [("historic", 0.9), ("foodie", 0.9), ("cosmopolitan", 0.85), ("coffee_culture", 0.8)],
    "cairo": [("historic", 0.95), ("affordable", 0.8)],
    "athens": [("historic", 0.95), ("beach_life", 0.7), ("foodie", 0.8), ("bohemian", 0.7)],
    "buenos-aires": [("nightlife", 0.85), ("foodie", 0.85), ("arts_music", 0.85), ("bohemian", 0.8), ("coffee_culture", 0.8)],
    "melbourne": [("coffee_culture", 0.95), ("foodie", 0.9), ("arts_music", 0.85), ("walkable", 0.8), ("lgbtq_friendly", 0.8)],
    "lisbon": [("historic", 0.8), ("digital_nomad", 0.9), ("foodie", 0.8), ("walkable", 0.75), ("bohemian", 0.75)],
    "budapest": [("historic", 0.85), ("nightlife", 0.85), ("affordable", 0.8), ("bohemian", 0.75), ("digital_nomad", 0.8)],
    "tbilisi": [("affordable", 0.9), ("digital_nomad", 0.9), ("foodie", 0.8), ("historic", 0.75), ("bohemian", 0.8)],
    "ho-chi-minh-city": [("affordable", 0.85), ("foodie", 0.85), ("digital_nomad", 0.85), ("fast_paced", 0.7)],
    "bangkok": [("foodie", 0.9), ("affordable", 0.8), ("nightlife", 0.85), ("digital_nomad", 0.8)],
    "singapore": [("fast_paced", 0.85), ("foodie", 0.85), ("luxury", 0.8), ("cosmopolitan", 0.9), ("walkable", 0.8)],
    "dubai": [("luxury", 0.95), ("fast_paced", 0.8), ("cosmopolitan", 0.85)],
    "abu-dhabi": [("luxury", 0.9), ("cosmopolitan", 0.75)],
    "doha": [("luxury", 0.85), ("fast_paced", 0.7)],
    "monaco": [("luxury", 0.95), ("cosmopolitan", 0.8)],
    "honolulu": [("beach_life", 0.95), ("outdoorsy", 0.9), ("luxury", 0.7)],
    "san-diego": [("beach_life", 0.9), ("outdoorsy", 0.85), ("foodie", 0.75)],
    "las-vegas": [("nightlife", 0.95), ("luxury", 0.7)],
    "washington": [("historic", 0.85), ("cosmopolitan", 0.8), ("arts_music", 0.8), ("walkable", 0.75)],
    "philadelphia": [("historic", 0.85), ("foodie", 0.8), ("arts_music", 0.75), ("walkable", 0.75)],
    "atlanta": [("nightlife", 0.8), ("arts_music", 0.75), ("foodie", 0.7)],
    "detroit": [("arts_music", 0.85), ("affordable", 0.8), ("bohemian", 0.7)],
    "memphis": [("arts_music", 0.9), ("foodie", 0.75)],
    "nashville": [("arts_music", 0.9), ("nightlife", 0.85), ("foodie", 0.8)],
    "oslo": [("eco_conscious", 0.9), ("outdoorsy", 0.85), ("luxury", 0.7)],
    "stockholm": [("eco_conscious", 0.85), ("cosmopolitan", 0.8), ("coffee_culture", 0.8)],
    "copenhagen": [("eco_conscious", 0.9), ("walkable", 0.85), ("foodie", 0.8), ("coffee_culture", 0.8)],
    "helsinki": [("eco_conscious", 0.85), ("coffee_culture", 0.8), ("family_friendly", 0.8)],
    "vienna": [("historic", 0.9), ("arts_music", 0.9), ("coffee_culture", 0.85), ("cosmopolitan", 0.8)],
    "prague": [("historic", 0.9), ("nightlife", 0.8), ("affordable", 0.7), ("bohemian", 0.8)],
    "krakow": [("historic", 0.85), ("affordable", 0.8), ("student_friendly", 0.8), ("bohemian", 0.75)],
    "mexico-city": [("foodie", 0.9), ("arts_music", 0.85), ("affordable", 0.75), ("bohemian", 0.8)],
    "medellin": [("digital_nomad", 0.85), ("affordable", 0.8), ("outdoorsy", 0.7), ("bohemian", 0.7)],
    "bogota": [("arts_music", 0.75), ("affordable", 0.75), ("foodie", 0.75)],
    "lima": [("foodie", 0.9), ("historic", 0.8), ("affordable", 0.7)],
    "moscow": [("historic", 0.85), ("arts_music", 0.85), ("fast_paced", 0.8), ("cosmopolitan", 0.75)],
    "saint-petersburg": [("historic", 0.9), ("arts_music", 0.9), ("cosmopolitan", 0.7)],
    "seoul": [("fast_paced", 0.85), ("foodie", 0.85), ("cosmopolitan", 0.8), ("coffee_culture", 0.8)],
    "taipei": [("foodie", 0.9), ("coffee_culture", 0.75), ("lgbtq_friendly", 0.8), ("affordable", 0.7)],
    "mumbai": [("fast_paced", 0.85), ("foodie", 0.8), ("cosmopolitan", 0.8), ("historic", 0.7)],
    "delhi": [("historic", 0.85), ("foodie", 0.8), ("fast_paced", 0.75)],
    "bengaluru": [("startup_hub", 0.85), ("digital_nomad", 0.7), ("affordable", 0.7)],
    "shanghai": [("fast_paced", 0.9), ("cosmopolitan", 0.85), ("luxury", 0.7), ("foodie", 0.8)],
    "beijing": [("historic", 0.9), ("fast_paced", 0.8), ("arts_music", 0.75)],
    "london": [("cosmopolitan", 0.95), ("historic", 0.9), ("arts_music", 0.9), ("nightlife", 0.85), ("foodie", 0.85), ("lgbtq_friendly", 0.85), ("walkable", 0.8)],
    "manchester": [("nightlife", 0.8), ("arts_music", 0.8), ("student_friendly", 0.8), ("bohemian", 0.7)],
    "milan": [("luxury", 0.85), ("foodie", 0.85), ("arts_music", 0.8), ("cosmopolitan", 0.8), ("fast_paced", 0.7)],
    "madrid": [("nightlife", 0.9), ("foodie", 0.85), ("arts_music", 0.85), ("walkable", 0.8), ("lgbtq_friendly", 0.8)],
    "valencia": [("beach_life", 0.8), ("foodie", 0.8), ("affordable", 0.7), ("digital_nomad", 0.7)],
    "malaga": [("beach_life", 0.85), ("digital_nomad", 0.8), ("affordable", 0.7)],
    "seville": [("historic", 0.85), ("nightlife", 0.8), ("foodie", 0.8)],
    "naples": [("foodie", 0.9), ("historic", 0.85), ("beach_life", 0.7)],
    "bologna": [("foodie", 0.9), ("historic", 0.8), ("student_friendly", 0.85), ("bohemian", 0.7)],
    "lyon": [("foodie", 0.9), ("historic", 0.8), ("arts_music", 0.75)],
    "porto": [("historic", 0.8), ("foodie", 0.8), ("affordable", 0.7), ("digital_nomad", 0.75), ("bohemian", 0.7)],
    "hamburg": [("nightlife", 0.8), ("arts_music", 0.8), ("cosmopolitan", 0.75)],
    "munich": [("beer", 0.9)],  # will be ignored, not a vibe key - just placeholder
    "san-jose": [("startup_hub", 0.9), ("fast_paced", 0.75)],
    "guadalajara": [("foodie", 0.8), ("affordable", 0.75), ("digital_nomad", 0.7), ("arts_music", 0.7)],
    "addis-ababa": [("coffee_culture", 0.9), ("historic", 0.7), ("affordable", 0.8)],
    "accra": [("affordable", 0.75), ("bohemian", 0.65), ("beach_life", 0.6)],
    "lagos": [("fast_paced", 0.8), ("nightlife", 0.75), ("affordable", 0.7)],
    "johannesburg": [("fast_paced", 0.7), ("nightlife", 0.7), ("arts_music", 0.7)],
    "salvador": [("beach_life", 0.85), ("nightlife", 0.85), ("arts_music", 0.8), ("historic", 0.75), ("bohemian", 0.75)],
    "recife": [("beach_life", 0.85), ("affordable", 0.75), ("bohemian", 0.65)],
    "curitiba": [("eco_conscious", 0.75), ("coffee_culture", 0.7), ("family_friendly", 0.7)],
    "brasilia": [("arts_music", 0.7), ("fast_paced", 0.65)],
    "fortaleza": [("beach_life", 0.9), ("affordable", 0.8)],
    "belo-horizonte": [("foodie", 0.75), ("affordable", 0.7)],
    "lviv": [("historic", 0.8), ("coffee_culture", 0.8), ("affordable", 0.85), ("bohemian", 0.75), ("digital_nomad", 0.7)],
    "kyiv": [("historic", 0.8), ("affordable", 0.8), ("arts_music", 0.7)],
    "vilnius": [("historic", 0.75), ("affordable", 0.75), ("bohemian", 0.7), ("digital_nomad", 0.7), ("coffee_culture", 0.7)],
    "riga": [("historic", 0.8), ("affordable", 0.7), ("arts_music", 0.7)],
    "tirana": [("affordable", 0.85), ("digital_nomad", 0.8), ("bohemian", 0.7)],
    "plovdiv": [("historic", 0.8), ("affordable", 0.85), ("bohemian", 0.7)],
    "sofia": [("affordable", 0.85), ("digital_nomad", 0.8), ("nightlife", 0.7)],
    "belgrade": [("nightlife", 0.85), ("affordable", 0.8), ("bohemian", 0.75), ("foodie", 0.7)],
    "luxembourg-city": [("luxury", 0.8), ("cosmopolitan", 0.75), ("family_friendly", 0.75)],
    "calgary": [("outdoorsy", 0.85), ("family_friendly", 0.75)],
    "edmonton": [("outdoorsy", 0.7), ("affordable", 0.7), ("family_friendly", 0.7)],
    "quebec-city": [("historic", 0.85), ("foodie", 0.75), ("family_friendly", 0.7)],
    "ottawa": [("historic", 0.7), ("family_friendly", 0.75), ("eco_conscious", 0.7)],
    "victoria": [("outdoorsy", 0.8), ("quiet_peaceful", 0.75), ("eco_conscious", 0.7)],
    "halifax": [("historic", 0.7), ("outdoorsy", 0.7), ("quiet_peaceful", 0.7)],
    "winnipeg": [("affordable", 0.7), ("arts_music", 0.65)],
    "gold-coast": [("beach_life", 0.95), ("outdoorsy", 0.8)],
    "adelaide": [("foodie", 0.75), ("quiet_peaceful", 0.7), ("family_friendly", 0.7)],
    "brisbane": [("outdoorsy", 0.75), ("beach_life", 0.7), ("family_friendly", 0.7)],
    "canberra": [("family_friendly", 0.75), ("outdoorsy", 0.7), ("quiet_peaceful", 0.7)],
    "hobart": [("outdoorsy", 0.8), ("quiet_peaceful", 0.8), ("coffee_culture", 0.7), ("bohemian", 0.65)],
    "perth": [("beach_life", 0.8), ("outdoorsy", 0.75), ("quiet_peaceful", 0.65)],
    "newcastle": [("beach_life", 0.75), ("outdoorsy", 0.7), ("affordable", 0.65)],
    "boise": [("outdoorsy", 0.85), ("quiet_peaceful", 0.7), ("affordable", 0.7), ("family_friendly", 0.7)],
    "colorado-springs": [("outdoorsy", 0.9), ("family_friendly", 0.7)],
    "madison": [("student_friendly", 0.85), ("eco_conscious", 0.7), ("quiet_peaceful", 0.65)],
    "durham": [("student_friendly", 0.85), ("foodie", 0.7)],
    "raleigh": [("startup_hub", 0.7), ("family_friendly", 0.7), ("student_friendly", 0.7)],
    "pittsburgh": [("affordable", 0.75), ("arts_music", 0.7), ("student_friendly", 0.7)],
    "richmond": [("historic", 0.75), ("foodie", 0.7), ("arts_music", 0.65)],
    "louisville": [("foodie", 0.7), ("affordable", 0.7)],
    "omaha": [("affordable", 0.75), ("family_friendly", 0.7)],
    "minneapolis": [("arts_music", 0.75), ("outdoorsy", 0.7), ("lgbtq_friendly", 0.7)],
    "milwaukee": [("affordable", 0.7), ("arts_music", 0.65)],
    "indianapolis": [("affordable", 0.75), ("family_friendly", 0.65)],
    "columbus": [("student_friendly", 0.75), ("affordable", 0.7)],
    "cincinnati": [("affordable", 0.75), ("foodie", 0.7), ("arts_music", 0.65)],
    "cleveland": [("affordable", 0.8), ("arts_music", 0.7)],
    "charlotte": [("fast_paced", 0.65), ("family_friendly", 0.65)],
    "st-louis": [("affordable", 0.75), ("arts_music", 0.7)],
    "kansas-city": [("affordable", 0.75), ("foodie", 0.7), ("arts_music", 0.7)],
    "oklahoma-city": [("affordable", 0.8)],
    "tulsa": [("affordable", 0.8)],
    "el-paso": [("affordable", 0.8)],
    "san-antonio": [("historic", 0.7), ("affordable", 0.7), ("foodie", 0.7)],
    "tucson": [("affordable", 0.75), ("outdoorsy", 0.7)],
    "albuquerque": [("outdoorsy", 0.75), ("affordable", 0.75), ("arts_music", 0.65)],
    "fresno": [("affordable", 0.75)],
    "mesa": [("affordable", 0.7), ("outdoorsy", 0.65)],
    "sacramento": [("affordable", 0.65), ("foodie", 0.65)],
    "reno": [("outdoorsy", 0.8), ("affordable", 0.7)],
    "fort-worth": [("affordable", 0.7), ("family_friendly", 0.65)],
    "phoenix": [("outdoorsy", 0.65), ("affordable", 0.65)],
    "quito": [("historic", 0.85), ("outdoorsy", 0.8), ("affordable", 0.75)],
    "guayaquil": [("affordable", 0.75), ("beach_life", 0.65)],
    "asuncion": [("affordable", 0.8)],
    "caracas": [("affordable", 0.7)],
    "cordoba": [("student_friendly", 0.8), ("affordable", 0.75), ("historic", 0.7)],
    "rosario": [("affordable", 0.75), ("student_friendly", 0.7)],
    "valparaiso": [("bohemian", 0.85), ("arts_music", 0.8), ("historic", 0.75)],
    "santa-cruz-de-la-sierra": [("affordable", 0.8)],
    "san-jose-costa-rica": [("eco_conscious", 0.75), ("outdoorsy", 0.75), ("digital_nomad", 0.7)],
    "panama-city": [("cosmopolitan", 0.65), ("beach_life", 0.65), ("fast_paced", 0.6)],
    "san-salvador": [("affordable", 0.75)],
    "guatemala-city": [("affordable", 0.8), ("historic", 0.65)],
    "tegucigalpa": [("affordable", 0.8)],
    "managua": [("affordable", 0.8)],
    "puebla": [("historic", 0.8), ("foodie", 0.8), ("affordable", 0.75)],
    "monterrey": [("fast_paced", 0.7), ("startup_hub", 0.65)],
    "muscat": [("luxury", 0.7), ("historic", 0.65), ("quiet_peaceful", 0.7)],
    "riyadh": [("fast_paced", 0.7), ("luxury", 0.7)],
    "jeddah": [("historic", 0.65), ("beach_life", 0.6)],
    "amman": [("historic", 0.8), ("affordable", 0.7)],
    "tehran": [("historic", 0.8), ("arts_music", 0.7)],
    "beirut": [("foodie", 0.85), ("nightlife", 0.8), ("historic", 0.75), ("cosmopolitan", 0.7)],
    "tashkent": [("historic", 0.7), ("affordable", 0.8)],
    "almaty": [("outdoorsy", 0.8), ("affordable", 0.75)],
    "astana": [("fast_paced", 0.65), ("affordable", 0.7)],
    "baku": [("historic", 0.7), ("fast_paced", 0.6)],
    "minsk": [("affordable", 0.8)],
    "skopje": [("affordable", 0.8), ("historic", 0.65)],
    "rotterdam": [("cosmopolitan", 0.7), ("eco_conscious", 0.7), ("arts_music", 0.7)],
    "the-hague": [("cosmopolitan", 0.7), ("family_friendly", 0.7), ("historic", 0.65)],
    "gothenburg": [("eco_conscious", 0.8), ("coffee_culture", 0.7), ("quiet_peaceful", 0.7)],
    "malmo": [("eco_conscious", 0.75), ("affordable", 0.65), ("coffee_culture", 0.7)],
    "zaragoza": [("historic", 0.7), ("affordable", 0.7)],
    "graz": [("historic", 0.7), ("student_friendly", 0.75), ("quiet_peaceful", 0.7), ("coffee_culture", 0.7)],
    "poznań": [("student_friendly", 0.75), ("affordable", 0.75), ("historic", 0.65)],
    "wrocław": [("student_friendly", 0.8), ("affordable", 0.75), ("bohemian", 0.7)],
    "kaunas": [("historic", 0.7), ("affordable", 0.75), ("student_friendly", 0.7)],
    "varna": [("beach_life", 0.8), ("affordable", 0.8), ("historic", 0.65)],
    "zagreb": [("historic", 0.7), ("affordable", 0.7), ("coffee_culture", 0.65)],
    "antwerp": [("historic", 0.75), ("foodie", 0.7), ("arts_music", 0.7)],
    "brussels": [("historic", 0.8), ("foodie", 0.8), ("cosmopolitan", 0.75), ("arts_music", 0.7)],
    "nantes": [("eco_conscious", 0.7), ("arts_music", 0.7), ("student_friendly", 0.7), ("foodie", 0.7)],
    "marseille": [("beach_life", 0.7), ("foodie", 0.8), ("nightlife", 0.7), ("bohemian", 0.65)],
    "montpellier": [("student_friendly", 0.8), ("beach_life", 0.65), ("bohemian", 0.65)],
    "bremen": [("historic", 0.7), ("student_friendly", 0.7), ("quiet_peaceful", 0.65)],
    "dortmund": [("affordable", 0.7), ("arts_music", 0.65)],
    "dresden": [("historic", 0.85), ("arts_music", 0.8), ("bohemian", 0.7)],
    "dusseldorf": [("cosmopolitan", 0.7), ("arts_music", 0.7), ("luxury", 0.65)],
    "frankfurt-am-main": [("fast_paced", 0.8), ("cosmopolitan", 0.8), ("startup_hub", 0.7)],
    "leipzig": [("bohemian", 0.85), ("arts_music", 0.85), ("affordable", 0.8), ("student_friendly", 0.75)],
    "nuremberg": [("historic", 0.8), ("family_friendly", 0.7)],
    "stuttgart": [("fast_paced", 0.7), ("eco_conscious", 0.65)],
    "glasgow": [("arts_music", 0.8), ("nightlife", 0.75), ("bohemian", 0.7), ("student_friendly", 0.7)],
    "birmingham": [("affordable", 0.65), ("historic", 0.65), ("student_friendly", 0.7)],
    "dhaka": [("affordable", 0.8), ("fast_paced", 0.7)],
    "chengdu": [("foodie", 0.85), ("affordable", 0.7)],
    "guangzhou": [("foodie", 0.8), ("fast_paced", 0.75)],
    "shenzhen": [("startup_hub", 0.85), ("fast_paced", 0.85)],
    "ahmedabad": [("historic", 0.7), ("affordable", 0.8)],
    "chennai": [("historic", 0.7), ("foodie", 0.75), ("affordable", 0.75), ("beach_life", 0.6)],
    "hyderabad": [("historic", 0.75), ("startup_hub", 0.7), ("affordable", 0.8)],
    "kolkata": [("historic", 0.8), ("arts_music", 0.75), ("affordable", 0.8), ("foodie", 0.75)],
    "surat": [("affordable", 0.85), ("fast_paced", 0.65)],
    "jakarta": [("fast_paced", 0.75), ("affordable", 0.7), ("foodie", 0.7)],
    "medan": [("affordable", 0.8), ("foodie", 0.65)],
    "baghdad": [("historic", 0.8), ("affordable", 0.75)],
    "karachi": [("fast_paced", 0.7), ("affordable", 0.8)],
    "lahore": [("historic", 0.8), ("foodie", 0.75), ("affordable", 0.8)],
    "manila": [("nightlife", 0.7), ("affordable", 0.75), ("digital_nomad", 0.65)],
    "busan": [("beach_life", 0.8), ("foodie", 0.8), ("outdoorsy", 0.7)],
    "taichung": [("foodie", 0.8), ("affordable", 0.7), ("coffee_culture", 0.65)],
    "kigali": [("eco_conscious", 0.75), ("quiet_peaceful", 0.65), ("affordable", 0.7)],
    "dakar": [("arts_music", 0.75), ("beach_life", 0.65), ("bohemian", 0.65), ("affordable", 0.75)],
    "dar-es-salaam": [("beach_life", 0.7), ("affordable", 0.8)],
    "kampala": [("affordable", 0.8)],
    "harare": [("affordable", 0.8)],
    "cali": [("nightlife", 0.8), ("affordable", 0.75), ("arts_music", 0.7)],
    "porto-alegre": [("affordable", 0.7), ("coffee_culture", 0.65)],
    "campinas": [("student_friendly", 0.75), ("startup_hub", 0.65)],
    "manaus": [("outdoorsy", 0.85), ("affordable", 0.75)],
    "montevideo": [("quiet_peaceful", 0.7), ("beach_life", 0.65), ("foodie", 0.7), ("family_friendly", 0.7)],
    "palermo": [("foodie", 0.85), ("historic", 0.8), ("beach_life", 0.65), ("bohemian", 0.65)],
    "turin": [("foodie", 0.8), ("historic", 0.75), ("arts_music", 0.7), ("bohemian", 0.65)],
    "genoa": [("historic", 0.8), ("foodie", 0.8), ("beach_life", 0.65)],
    "long-beach": [("beach_life", 0.85), ("nightlife", 0.65), ("lgbtq_friendly", 0.65)],
    "oakland": [("bohemian", 0.8), ("foodie", 0.8), ("arts_music", 0.75), ("lgbtq_friendly", 0.75)],
    "orlando": [("family_friendly", 0.8), ("beach_life", 0.6)],
    "tampa": [("beach_life", 0.8), ("nightlife", 0.65), ("family_friendly", 0.6)],
    "st-petersburg": [("beach_life", 0.85), ("arts_music", 0.7), ("quiet_peaceful", 0.65)],
    "dallas": [("fast_paced", 0.75), ("foodie", 0.7)],
    "houston": [("foodie", 0.8), ("cosmopolitan", 0.7), ("fast_paced", 0.7)],
    "baltimore": [("historic", 0.75), ("arts_music", 0.7), ("affordable", 0.7)],
}


def clamp(val, lo=0.3, hi=1.0):
    return max(lo, min(hi, round(val, 2)))


def compute_vibes(city):
    """Return dict of vibe_key -> strength for a city."""
    s = city["scores"]
    cid = city["id"]
    name = city["name"]
    country = city.get("country", "")
    pop = city.get("population", 0)
    lat = city.get("latitude", 0)

    vibes = {}

    # ── Score-based rules ────────────────────────────────────────────

    # Walkable: Commute > 7 or well-known walkable
    commute = s.get("Commute", 0)
    if commute > 7:
        vibes["walkable"] = clamp(0.6 + (commute - 7) * 0.1)
    elif commute > 6:
        vibes["walkable"] = clamp(0.5 + (commute - 6) * 0.1)

    # Nightlife: Leisure > 7 AND in nightlife set
    leisure = s.get("Leisure & Culture", 0)
    if cid in NIGHTLIFE_CITIES:
        strength = clamp(0.5 + (leisure - 5) * 0.08)
        vibes["nightlife"] = clamp(max(strength, 0.6))

    # Foodie: Leisure > 7 or in foodie set
    if leisure > 7 or cid in FOODIE_CITIES:
        base = 0.55 + (leisure - 5) * 0.07
        if cid in FOODIE_CITIES:
            base += 0.1
        vibes["foodie"] = clamp(base)

    # Beach Life: coastal warm cities
    if cid in COASTAL_WARM:
        # Warmer latitudes get higher strength
        abs_lat = abs(lat)
        if abs_lat < 25:
            vibes["beach_life"] = clamp(0.8)
        elif abs_lat < 35:
            vibes["beach_life"] = clamp(0.7)
        else:
            vibes["beach_life"] = clamp(0.55)

    # Outdoorsy: Outdoors > 7
    outdoors = s.get("Outdoors", 0)
    if outdoors > 7:
        vibes["outdoorsy"] = clamp(0.6 + (outdoors - 7) * 0.1)
    elif outdoors > 6:
        vibes["outdoorsy"] = clamp(0.5 + (outdoors - 6) * 0.1)

    # Coffee Culture
    if cid in COFFEE_CITIES:
        vibes["coffee_culture"] = clamp(0.65)

    # Luxury: low Cost of Living (expensive) or in luxury set
    col = s.get("Cost of Living", 5)
    if col <= 2.5 or cid in LUXURY_CITIES:
        base = 0.5
        if col <= 1.5:
            base = 0.85
        elif col <= 2.5:
            base = 0.7
        if cid in LUXURY_CITIES:
            base = max(base, 0.7)
        vibes["luxury"] = clamp(base)

    # Arts & Music: high Leisure
    if leisure > 7.5:
        vibes["arts_music"] = clamp(0.6 + (leisure - 7) * 0.1)
    elif leisure > 6.5:
        vibes["arts_music"] = clamp(0.5 + (leisure - 6) * 0.1)

    # Historic
    if cid in HISTORIC_CITIES:
        vibes["historic"] = clamp(0.7)

    # Cosmopolitan: Travel Connectivity + Tolerance + large pop
    travel = s.get("Travel Connectivity", 0)
    tolerance = s.get("Tolerance", 0)
    if travel > 7 and tolerance > 7:
        vibes["cosmopolitan"] = clamp(0.6 + (travel + tolerance - 14) * 0.05)
    elif travel > 7 and tolerance > 6:
        vibes["cosmopolitan"] = clamp(0.55)

    # Bohemian
    if cid in BOHEMIAN_CITIES:
        vibes["bohemian"] = clamp(0.65)

    # Fast-Paced: Economy > 7
    economy = s.get("Economy", 0)
    if economy > 7:
        vibes["fast_paced"] = clamp(0.6 + (economy - 7) * 0.1)
    elif economy > 6.5:
        vibes["fast_paced"] = clamp(0.55)

    # Quiet & Peaceful: smaller cities, high safety, not major metros
    safety = s.get("Safety", 0)
    if safety > 7 and pop < 1_500_000:
        vibes["quiet_peaceful"] = clamp(0.5 + (safety - 7) * 0.1)
    elif safety > 8 and pop < 3_000_000:
        vibes["quiet_peaceful"] = clamp(0.5)

    # Eco-Conscious: Environmental Quality > 7
    env_q = s.get("Environmental Quality", 0)
    if env_q > 7:
        vibes["eco_conscious"] = clamp(0.5 + (env_q - 7) * 0.15)
    elif env_q > 6.5:
        vibes["eco_conscious"] = clamp(0.45)

    # Family Friendly: Safety + Education + Healthcare all > 7
    education = s.get("Education", 0)
    healthcare = s.get("Healthcare", 0)
    if safety > 7 and education > 7 and healthcare > 7:
        avg = (safety + education + healthcare) / 3
        vibes["family_friendly"] = clamp(0.5 + (avg - 7) * 0.15)

    # LGBTQ+ Friendly: High tolerance in progressive cities
    if tolerance > 8:
        vibes["lgbtq_friendly"] = clamp(0.6 + (tolerance - 8) * 0.15)
    elif tolerance > 7:
        vibes["lgbtq_friendly"] = clamp(0.5 + (tolerance - 7) * 0.1)

    # Affordable: High Housing + Cost of Living (cheap cities)
    housing = s.get("Housing", 0)
    if col > 7 and housing > 5:
        avg_afford = (col + housing) / 2
        vibes["affordable"] = clamp(0.5 + (avg_afford - 6) * 0.12)
    elif col > 7:
        vibes["affordable"] = clamp(0.5 + (col - 7) * 0.1)

    # Digital Nomad: affordable + internet + nomad destination
    internet = s.get("Internet Access", 0)
    if cid in NOMAD_CITIES:
        base = 0.6
        if col > 6:
            base += 0.1
        if internet > 7:
            base += 0.1
        vibes["digital_nomad"] = clamp(base)
    elif col > 6.5 and internet > 7:
        vibes["digital_nomad"] = clamp(0.5)

    # Startup Hub: Startups + VC
    startups = s.get("Startups", 0)
    vc = s.get("Venture Capital", 0)
    if startups > 7 or vc > 7:
        avg_start = (startups + vc) / 2
        vibes["startup_hub"] = clamp(0.5 + (avg_start - 5) * 0.08)
    elif startups > 6 and vc > 4:
        vibes["startup_hub"] = clamp(0.5)

    # Student Friendly: Education > 7 + university cities
    if education > 7.5:
        vibes["student_friendly"] = clamp(0.5 + (education - 7) * 0.12)

    # ── Apply manual overrides (override computed values) ────────────
    if cid in MANUAL_OVERRIDES:
        for vibe_key, strength in MANUAL_OVERRIDES[cid]:
            if vibe_key in VIBES:  # only valid keys
                vibes[vibe_key] = clamp(strength)

    # ── Ensure 5-10 vibes ────────────────────────────────────────────
    # Sort by strength descending, keep top 10
    if len(vibes) > 10:
        sorted_vibes = sorted(vibes.items(), key=lambda x: -x[1])
        vibes = dict(sorted_vibes[:10])

    # If fewer than 5, add some reasonable defaults based on highest scores
    if len(vibes) < 5:
        # Try to add more vibes based on available data
        candidates = []

        if "walkable" not in vibes and commute > 5:
            candidates.append(("walkable", clamp(0.3 + commute * 0.05)))
        if "arts_music" not in vibes and leisure > 5.5:
            candidates.append(("arts_music", clamp(0.3 + (leisure - 5) * 0.08)))
        if "foodie" not in vibes and leisure > 5.5:
            candidates.append(("foodie", clamp(0.3 + (leisure - 5) * 0.07)))
        if "outdoorsy" not in vibes and outdoors > 5:
            candidates.append(("outdoorsy", clamp(0.3 + (outdoors - 5) * 0.08)))
        if "family_friendly" not in vibes and safety > 5.5 and education > 5.5:
            candidates.append(("family_friendly", clamp(0.3 + (safety + education - 11) * 0.06)))
        if "affordable" not in vibes and col > 5:
            candidates.append(("affordable", clamp(0.3 + (col - 5) * 0.08)))
        if "fast_paced" not in vibes and economy > 5.5:
            candidates.append(("fast_paced", clamp(0.3 + (economy - 5) * 0.07)))
        if "eco_conscious" not in vibes and env_q > 5.5:
            candidates.append(("eco_conscious", clamp(0.3 + (env_q - 5) * 0.08)))
        if "student_friendly" not in vibes and education > 6:
            candidates.append(("student_friendly", clamp(0.3 + (education - 5) * 0.07)))
        if "cosmopolitan" not in vibes and travel > 5.5:
            candidates.append(("cosmopolitan", clamp(0.3 + (travel - 5) * 0.06)))
        if "lgbtq_friendly" not in vibes and tolerance > 6:
            candidates.append(("lgbtq_friendly", clamp(0.3 + (tolerance - 5) * 0.07)))
        if "quiet_peaceful" not in vibes and safety > 6 and pop < 2_000_000:
            candidates.append(("quiet_peaceful", clamp(0.3 + (safety - 5) * 0.07)))
        if "digital_nomad" not in vibes and internet > 6 and col > 5:
            candidates.append(("digital_nomad", clamp(0.3 + (internet - 6) * 0.05)))

        # Sort candidates by strength desc, add until we have 5
        candidates.sort(key=lambda x: -x[1])
        for vibe_key, strength in candidates:
            if len(vibes) >= 5:
                break
            if vibe_key not in vibes:
                vibes[vibe_key] = strength

    return vibes


def run_query(sql):
    """Execute SQL via Supabase Management API."""
    resp = requests.post(API_URL, headers=HEADERS, json={"query": sql})
    if resp.status_code != 201 and resp.status_code != 200:
        print(f"  ERROR {resp.status_code}: {resp.text[:500]}")
        return None
    return resp.json()


def main():
    # Load cities
    with open("/Users/burke/Documents/TeleportMe/supabase/curated_cities_data.json") as f:
        cities = json.load(f)

    print(f"Loaded {len(cities)} cities")

    # Compute all vibe assignments
    all_rows = []
    for city in cities:
        vibes = compute_vibes(city)
        for vibe_key, strength in vibes.items():
            vibe_uuid = VIBES[vibe_key]
            all_rows.append((city["id"], vibe_uuid, strength))

    print(f"Computed {len(all_rows)} city-vibe tag mappings")

    # Stats
    vibe_counts = {}
    for _, vibe_uuid, _ in all_rows:
        # reverse lookup
        for k, v in VIBES.items():
            if v == vibe_uuid:
                vibe_counts[k] = vibe_counts.get(k, 0) + 1
                break
    print("\nVibe tag distribution:")
    for k, v in sorted(vibe_counts.items(), key=lambda x: -x[1]):
        print(f"  {k}: {v} cities")

    # Check per-city counts
    city_counts = {}
    for city_id, _, _ in all_rows:
        city_counts[city_id] = city_counts.get(city_id, 0) + 1
    min_c = min(city_counts.values())
    max_c = max(city_counts.values())
    avg_c = sum(city_counts.values()) / len(city_counts)
    print(f"\nVibes per city: min={min_c}, max={max_c}, avg={avg_c:.1f}")

    # Cities with < 5 vibes (should be none)
    under5 = [cid for cid, cnt in city_counts.items() if cnt < 5]
    if under5:
        print(f"WARNING: {len(under5)} cities with < 5 vibes: {under5}")

    # Batch insert
    BATCH_SIZE = 100
    total_batches = math.ceil(len(all_rows) / BATCH_SIZE)
    print(f"\nInserting in {total_batches} batches of up to {BATCH_SIZE} rows...")

    for i in range(0, len(all_rows), BATCH_SIZE):
        batch = all_rows[i:i + BATCH_SIZE]
        batch_num = i // BATCH_SIZE + 1

        values = []
        for city_id, vibe_uuid, strength in batch:
            # Escape single quotes in city_id just in case
            safe_id = city_id.replace("'", "''")
            values.append(f"('{safe_id}', '{vibe_uuid}', {strength})")

        sql = (
            "INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES\n"
            + ",\n".join(values)
            + "\nON CONFLICT (city_id, vibe_tag_id) DO NOTHING;"
        )

        print(f"  Batch {batch_num}/{total_batches}: {len(batch)} rows...", end=" ")
        result = run_query(sql)
        if result is not None:
            print("OK")
        else:
            print("FAILED")

        # Small delay to be polite to the API
        if batch_num < total_batches:
            time.sleep(0.5)

    # Verify
    print("\nVerifying...")
    time.sleep(1)
    result = run_query("SELECT COUNT(*) as total FROM city_vibe_tags;")
    if result:
        print(f"Total city_vibe_tags rows: {result}")
    else:
        print("Could not verify count.")

    # Also count distinct cities
    result2 = run_query("SELECT COUNT(DISTINCT city_id) as cities FROM city_vibe_tags;")
    if result2:
        print(f"Distinct cities with vibe tags: {result2}")

    print("\nDone!")


if __name__ == "__main__":
    main()
