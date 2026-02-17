#!/usr/bin/env python3
"""
compile_cities.py

Reads city lists from multiple source files across different regions,
normalizes and deduplicates entries, filters out non-city entries and
existing cities already in the database, and outputs a master JSON
list of new cities.
"""

import json
import re
import os
import unicodedata
from collections import defaultdict

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE = "/Users/burke/Documents/teleport-api/countries"
OUTPUT_DIR = "/Users/burke/Documents/TeleportMe/supabase"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "new_cities_master.json")

SOURCE_FILES = {
    "USA.md":                  {"path": os.path.join(BASE, "USA.md"),                  "continent": "North America"},
    "Europe.md":               {"path": os.path.join(BASE, "Europe.md"),               "continent": "Europe"},
    "Asia":                    {"path": os.path.join(BASE, "Asia"),                    "continent": "Asia"},
    "Africa":                  {"path": os.path.join(BASE, "Africa"),                  "continent": "Africa"},
    "MiddleEast":              {"path": os.path.join(BASE, "MiddleEast"),              "continent": "Middle East"},
    "Americas+Australia.csv":  {"path": os.path.join(BASE, "Americas+Australia.csv"),  "continent": "auto"},
}

# ── US State abbreviation mapping ──────────────────────────────────────────────
US_STATES = {
    "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
    "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
    "FL": "Florida", "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho",
    "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas",
    "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
    "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
    "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada",
    "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York",
    "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma",
    "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina",
    "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah",
    "VT": "Vermont", "VA": "Virginia", "WA": "Washington", "WV": "West Virginia",
    "WI": "Wisconsin", "WY": "Wyoming", "DC": "District of Columbia",
}

# ── Existing 55 cities in the database (by slug) ──────────────────────────────
EXISTING_CITY_IDS = {
    "amsterdam", "auckland", "austin", "bali", "bangkok", "barcelona",
    "berlin", "bogota", "boston", "buenos-aires", "cape-town", "charleston",
    "chicago", "copenhagen", "denver", "dubai", "dublin", "edinburgh",
    "helsinki", "hong-kong", "kuala-lumpur", "lisbon", "london",
    "los-angeles", "medellin", "melbourne", "mexico-city", "miami",
    "montreal", "munich", "nairobi", "nashville", "new-york", "osaka",
    "paris", "portland", "prague", "reykjavik", "san-francisco", "santiago",
    "sao-paulo", "seattle", "seoul", "singapore", "stockholm", "sydney",
    "taipei", "tallinn", "tel-aviv", "tokyo", "toronto", "vancouver",
    "vienna", "warsaw", "zurich",
}

# ── Country → continent mapping for Americas+Australia.csv ─────────────────────
COUNTRY_CONTINENT = {
    # North America
    "Canada": "North America", "Mexico": "North America",
    # Central America
    "Guatemala": "Central America", "Honduras": "Central America",
    "El Salvador": "Central America", "Nicaragua": "Central America",
    "Costa Rica": "Central America", "Panama": "Central America",
    "Belize": "Central America",
    # Caribbean
    "Dominican Republic": "Caribbean", "Cuba": "Caribbean",
    "Jamaica": "Caribbean", "Haiti": "Caribbean",
    "Trinidad and Tobago": "Caribbean", "Puerto Rico": "Caribbean",
    # South America
    "Argentina": "South America", "Brazil": "South America",
    "Colombia": "South America", "Peru": "South America",
    "Chile": "South America", "Ecuador": "South America",
    "Bolivia": "South America", "Paraguay": "South America",
    "Uruguay": "South America", "Venezuela": "South America",
    "Guyana": "South America", "Suriname": "South America",
    # Oceania
    "Australia": "Oceania", "New Zealand": "Oceania",
    "Fiji": "Oceania", "Papua New Guinea": "Oceania",
    "Samoa": "Oceania",
}

# ── Helpers ────────────────────────────────────────────────────────────────────

def normalize_unicode(text):
    """Normalize unicode characters (curly quotes, non-breaking hyphens, etc.)."""
    text = text.replace("\u2011", "-")   # non-breaking hyphen
    text = text.replace("\u2010", "-")   # hyphen
    # Keep en/em dashes for junk detection, but normalize to a single marker
    text = text.replace("\u2013", "\u2013")  # keep en-dash as-is for detection
    text = text.replace("\u2014", "\u2013")  # normalize em-dash to en-dash
    text = text.replace("\u2018", "'").replace("\u2019", "'")
    text = text.replace("\u201c", '"').replace("\u201d", '"')
    return text


def slugify(city_name):
    """Convert city name to a URL-friendly slug for matching against existing IDs."""
    s = unicodedata.normalize("NFKD", city_name)
    s = s.encode("ascii", "ignore").decode("ascii")
    s = s.lower().strip()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = s.strip("-")
    return s


def is_junk_entry(line):
    """Return True if the line looks like a non-city annotation."""
    low = line.lower()
    # Use word-boundary matching to avoid false positives (e.g., "rank" in "Frankfurt")
    junk_patterns = [
        r'\btie\b', r'\bregion\b', r'\bmetro\b', r'\bgrouping\b',
        r'\bambiguous\b', r'\brank\b', r'\bsimilar\b',
    ]
    for pattern in junk_patterns:
        if re.search(pattern, low):
            return True
    # Lines containing " / " are compound/ambiguous entries
    if " / " in line:
        return True
    # Bare "/" adjacent to text with parentheses (e.g., "Linz (Austria)/ similar ~90")
    if "/" in line and "(" in line:
        return True
    # Lines containing en-dash or em-dash (editorial annotations)
    if "\u2013" in line:
        return True
    return False


def clean_line(line):
    """Strip trailing annotations like //, trailing periods, parenthetical notes."""
    line = line.strip()
    # Remove trailing "//" markers
    line = re.sub(r"\s*//\s*$", "", line)
    # Remove trailing period (e.g., "Modesto, CA.")
    line = re.sub(r"\.\s*$", "", line)
    # Remove trailing parenthetical annotations like "(often counted as both Europe and Asia)"
    line = re.sub(r"\s*\(often counted.*\)\s*$", "", line)
    # Remove "(regional)" type suffixes
    line = re.sub(r"\s*\(regional\)\s*", " ", line)
    return line.strip()


def parse_usa_line(line):
    """Parse a USA city line like 'New York, NY' -> dict."""
    line = clean_line(line)
    if not line or "," not in line:
        return None
    parts = [p.strip() for p in line.split(",", 1)]
    if len(parts) != 2:
        return None
    city_name = parts[0].strip()
    state_abbr = parts[1].strip().upper()
    state_full = US_STATES.get(state_abbr, state_abbr)
    return {
        "name": city_name,
        "state_or_region": state_full,
        "country": "United States",
    }


def parse_international_line(line):
    """Parse an international city line like 'Berlin, Germany'."""
    line = clean_line(line)
    if not line or "," not in line:
        return None

    # Handle "Astana (Nur-Sultan), Kazakhstan" style
    city_part, country = line.rsplit(",", 1)
    city_part = city_part.strip()
    country = country.strip()

    # Remove parenthetical aliases from city name
    city_name = re.sub(r"\s*\(.*?\)\s*", "", city_part).strip()

    if not city_name:
        return None

    return {
        "name": city_name,
        "state_or_region": "",
        "country": country,
    }


def determine_continent_for_americas_australia(country):
    """Determine continent based on country for Americas+Australia.csv."""
    return COUNTRY_CONTINENT.get(country, "Other")


def dedup_key(entry):
    """Create a deduplication key from a city entry."""
    name = slugify(entry["name"])
    country = slugify(entry["country"])
    return f"{name}|{country}"


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    all_entries = []
    skipped_junk = []
    stats = defaultdict(int)

    for file_label, info in SOURCE_FILES.items():
        filepath = info["path"]
        default_continent = info["continent"]

        if not os.path.exists(filepath):
            print(f"WARNING: File not found: {filepath}")
            continue

        with open(filepath, "r", encoding="utf-8") as f:
            raw_lines = f.readlines()

        for raw_line in raw_lines:
            line = normalize_unicode(raw_line).strip()
            if not line:
                continue

            # Filter junk
            if is_junk_entry(line):
                skipped_junk.append((file_label, line))
                stats["junk_filtered"] += 1
                continue

            # Parse based on source
            if file_label == "USA.md":
                entry = parse_usa_line(line)
                if entry:
                    entry["continent"] = "North America"
                    entry["source_file"] = file_label
                    all_entries.append(entry)
                    stats["parsed"] += 1
            else:
                entry = parse_international_line(line)
                if entry:
                    if default_continent == "auto":
                        entry["continent"] = determine_continent_for_americas_australia(entry["country"])
                    else:
                        entry["continent"] = default_continent
                    entry["source_file"] = file_label
                    all_entries.append(entry)
                    stats["parsed"] += 1

    total_parsed = len(all_entries)
    print(f"Total city entries parsed (before dedup): {total_parsed}")
    print(f"Junk entries filtered out: {stats['junk_filtered']}")
    if skipped_junk:
        print("\nFiltered junk entries:")
        for src, line in skipped_junk:
            print(f"  [{src}] {line}")

    # ── Deduplicate ────────────────────────────────────────────────────────────
    seen = {}
    duplicates_removed = 0
    for entry in all_entries:
        key = dedup_key(entry)
        if key not in seen:
            seen[key] = entry
        else:
            duplicates_removed += 1

    unique_entries = list(seen.values())
    print(f"\nDuplicates removed: {duplicates_removed}")
    print(f"Unique cities after dedup: {len(unique_entries)}")

    # ── Filter out existing cities ─────────────────────────────────────────────
    new_cities = []
    existing_matched = []
    for entry in unique_entries:
        slug = slugify(entry["name"])
        if slug in EXISTING_CITY_IDS:
            existing_matched.append(entry["name"])
        else:
            new_cities.append(entry)

    print(f"\nExisting cities matched and filtered out ({len(existing_matched)}):")
    for name in sorted(set(existing_matched)):
        print(f"  - {name}")

    print(f"\nNew cities remaining: {len(new_cities)}")

    # ── Sort output ────────────────────────────────────────────────────────────
    new_cities.sort(key=lambda e: (e["continent"], e["country"], e["name"]))

    # ── Continent breakdown ────────────────────────────────────────────────────
    continent_counts = defaultdict(int)
    for entry in new_cities:
        continent_counts[entry["continent"]] += 1

    print("\nBreakdown by continent:")
    for continent in sorted(continent_counts.keys()):
        print(f"  {continent}: {continent_counts[continent]}")
    print(f"  TOTAL: {sum(continent_counts.values())}")

    # ── Write JSON ─────────────────────────────────────────────────────────────
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(new_cities, f, indent=2, ensure_ascii=False)

    print(f"\nOutput written to: {OUTPUT_FILE}")
    print(f"Total new cities in JSON: {len(new_cities)}")

    # ── Summary ────────────────────────────────────────────────────────────────
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"  Total entries parsed:          {total_parsed}")
    print(f"  Junk entries filtered:         {stats['junk_filtered']}")
    print(f"  Duplicates removed:            {duplicates_removed}")
    print(f"  Existing cities filtered out:  {len(existing_matched)}")
    print(f"  New cities remaining:          {len(new_cities)}")
    print("=" * 60)


if __name__ == "__main__":
    main()
