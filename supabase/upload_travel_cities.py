#!/usr/bin/env python3
"""
Upload 156 travel cities from travel_cities_enriched.json to Supabase
via the Management API (database/query endpoint).
"""

import json
import time
import requests

# ── Config ──────────────────────────────────────────────────────────────────
JSON_PATH = "/Users/burke/Documents/TeleportMe/supabase/travel_cities_enriched.json"
API_URL = "https://api.supabase.com/v1/projects/fpdkmurgoqjplbbxlpkl/database/query"
HEADERS = {
    "Authorization": "Bearer sbp_6ae0c0d7893b10a48a85081fe71faa38250280d2",
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0",
}

CITY_BATCH_SIZE = 15        # cities per INSERT batch
SCORE_BATCH_SIZE = 40       # cities worth of scores per INSERT batch (40 * 17 = 680 rows)


# ── Helpers ─────────────────────────────────────────────────────────────────
def esc(value: str) -> str:
    """Escape single quotes for SQL strings."""
    return value.replace("'", "''")


def run_query(sql: str) -> "requests.Response":
    """Execute a SQL query via the Supabase Management API."""
    resp = requests.post(API_URL, headers=HEADERS, json={"query": sql}, timeout=30)
    if resp.status_code != 201:
        print(f"  ERROR {resp.status_code}: {resp.text[:500]}")
    return resp


# ── Load data ───────────────────────────────────────────────────────────────
with open(JSON_PATH, "r") as f:
    cities = json.load(f)

print(f"Loaded {len(cities)} cities from {JSON_PATH}\n")


# ── 1) Insert cities in batches of 15 ──────────────────────────────────────
print("=" * 60)
print("STEP 1: Inserting cities")
print("=" * 60)

for i in range(0, len(cities), CITY_BATCH_SIZE):
    batch = cities[i : i + CITY_BATCH_SIZE]
    rows = []
    for c in batch:
        img = "NULL" if not c.get("image_url") else f"'{esc(c['image_url'])}'"
        row = (
            f"('{esc(c['id'])}', '{esc(c['name'])}', '{esc(c['full_name'])}', "
            f"'{esc(c['country'])}', '{esc(c['continent'])}', "
            f"{c['latitude']}, {c['longitude']}, {c['population']}, "
            f"{c['teleport_city_score']}, '{esc(c['summary'])}', {img})"
        )
        rows.append(row)

    sql = (
        "INSERT INTO cities "
        "(id, name, full_name, country, continent, latitude, longitude, "
        "population, teleport_city_score, summary, image_url) VALUES\n"
        + ",\n".join(rows)
        + "\nON CONFLICT (id) DO NOTHING;"
    )

    batch_end = min(i + CITY_BATCH_SIZE, len(cities))
    print(f"  Batch {i+1}-{batch_end} of {len(cities)} ...", end=" ")
    resp = run_query(sql)
    if resp.status_code == 201:
        print("OK")
    time.sleep(0.3)


# ── 2) Insert city_scores in batches of 40 cities ──────────────────────────
print()
print("=" * 60)
print("STEP 2: Inserting city_scores")
print("=" * 60)

for i in range(0, len(cities), SCORE_BATCH_SIZE):
    batch = cities[i : i + SCORE_BATCH_SIZE]
    rows = []
    for c in batch:
        for category, score in c.get("scores", {}).items():
            rows.append(
                f"('{esc(c['id'])}', '{esc(category)}', {score})"
            )

    sql = (
        "INSERT INTO city_scores (city_id, category, score) VALUES\n"
        + ",\n".join(rows)
        + "\nON CONFLICT (city_id, category) DO NOTHING;"
    )

    batch_end = min(i + SCORE_BATCH_SIZE, len(cities))
    print(f"  Batch cities {i+1}-{batch_end} ({len(rows)} score rows) ...", end=" ")
    resp = run_query(sql)
    if resp.status_code == 201:
        print("OK")
    time.sleep(0.3)


# ── 3) Verify ──────────────────────────────────────────────────────────────
print()
print("=" * 60)
print("STEP 3: Verification")
print("=" * 60)

resp = run_query("SELECT COUNT(*) AS total_cities FROM cities;")
if resp.status_code == 201:
    data = resp.json()
    print(f"  Total cities in DB:       {data}")

resp = run_query("SELECT COUNT(*) AS total_scores FROM city_scores;")
if resp.status_code == 201:
    data = resp.json()
    print(f"  Total city_scores in DB:  {data}")

resp = run_query(
    "SELECT COUNT(DISTINCT city_id) AS cities_with_scores FROM city_scores;"
)
if resp.status_code == 201:
    data = resp.json()
    print(f"  Distinct cities w/scores: {data}")

print("\nDone!")
