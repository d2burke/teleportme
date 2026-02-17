#!/usr/bin/env python3
"""Upload curated_cities_data.json to Supabase via Management API."""

import json
import sys
import time
import urllib.request
import urllib.error

# --- Config ---
API_URL = "https://api.supabase.com/v1/projects/fpdkmurgoqjplbbxlpkl/database/query"
AUTH_TOKEN = "sbp_6ae0c0d7893b10a48a85081fe71faa38250280d2"
DATA_FILE = "/Users/burke/Documents/TeleportMe/supabase/curated_cities_data.json"
USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"

CITY_BATCH_SIZE = 20
SCORE_BATCH_CITIES = 50  # 50 cities * 17 categories = 850 rows per batch


def escape_sql(value: str) -> str:
    """Escape single quotes for SQL strings."""
    return value.replace("'", "''")


def run_query(sql: str) -> dict:
    """Execute a SQL query via the Supabase Management API."""
    payload = json.dumps({"query": sql}).encode("utf-8")
    req = urllib.request.Request(
        API_URL,
        data=payload,
        headers={
            "Authorization": f"Bearer {AUTH_TOKEN}",
            "Content-Type": "application/json",
            "User-Agent": USER_AGENT,
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            body = resp.read().decode("utf-8")
            return json.loads(body)
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")
        print(f"  HTTP {e.code}: {error_body[:500]}", file=sys.stderr)
        raise
    except Exception as e:
        print(f"  Request error: {e}", file=sys.stderr)
        raise


def build_city_values(city: dict) -> str:
    """Build a single VALUES tuple for one city row."""
    cid = escape_sql(city["id"])
    name = escape_sql(city["name"])
    full_name = escape_sql(city["full_name"])
    country = escape_sql(city["country"])
    continent = escape_sql(city["continent"])
    lat = city["latitude"]
    lng = city["longitude"]
    pop = city["population"]
    score = city["teleport_city_score"]
    summary = escape_sql(city["summary"])
    image_url = city.get("image_url", "")
    if image_url:
        img_sql = f"'{escape_sql(image_url)}'"
    else:
        img_sql = "NULL"

    return (
        f"('{cid}', '{name}', '{full_name}', '{country}', '{continent}', "
        f"{lat}, {lng}, {pop}, {score}, '{summary}', {img_sql}, NOW(), NOW())"
    )


def build_score_values(city_id: str, scores: dict) -> list[str]:
    """Build VALUES tuples for all scores of one city."""
    tuples = []
    for category, score_val in scores.items():
        cid = escape_sql(city_id)
        cat = escape_sql(category)
        tuples.append(f"('{cid}', '{cat}', {score_val})")
    return tuples


def main():
    # Load data
    with open(DATA_FILE, "r") as f:
        cities = json.load(f)

    total_cities = len(cities)
    print(f"Loaded {total_cities} cities from JSON.\n")

    # ---- Insert cities in batches of 20 ----
    cities_inserted = 0
    cities_errors = 0

    for i in range(0, total_cities, CITY_BATCH_SIZE):
        batch = cities[i : i + CITY_BATCH_SIZE]
        values = ",\n".join(build_city_values(c) for c in batch)
        sql = (
            "INSERT INTO cities (id, name, full_name, country, continent, "
            "latitude, longitude, population, teleport_city_score, summary, "
            "image_url, created_at, updated_at)\nVALUES\n"
            + values
            + "\nON CONFLICT (id) DO NOTHING;"
        )

        batch_start = i + 1
        batch_end = min(i + CITY_BATCH_SIZE, total_cities)
        print(f"Cities batch {batch_start}-{batch_end}...", end=" ", flush=True)

        try:
            result = run_query(sql)
            if isinstance(result, dict) and "error" in result:
                print(f"ERROR: {result['error']}")
                cities_errors += len(batch)
            else:
                cities_inserted += len(batch)
                print("OK")
        except Exception as e:
            print(f"FAILED: {e}")
            cities_errors += len(batch)

        time.sleep(0.3)  # Rate-limit courtesy

    print(f"\nCities: {cities_inserted} sent, {cities_errors} errored.\n")

    # ---- Insert scores in batches of 50 cities ----
    scores_inserted = 0
    scores_errors = 0

    for i in range(0, total_cities, SCORE_BATCH_CITIES):
        batch = cities[i : i + SCORE_BATCH_CITIES]
        all_values = []
        for c in batch:
            all_values.extend(build_score_values(c["id"], c.get("scores", {})))

        values_str = ",\n".join(all_values)
        sql = (
            "INSERT INTO city_scores (city_id, category, score)\nVALUES\n"
            + values_str
            + "\nON CONFLICT (city_id, category) DO NOTHING;"
        )

        batch_start = i + 1
        batch_end = min(i + SCORE_BATCH_CITIES, total_cities)
        row_count = len(all_values)
        print(
            f"Scores batch (cities {batch_start}-{batch_end}, {row_count} rows)...",
            end=" ",
            flush=True,
        )

        try:
            result = run_query(sql)
            if isinstance(result, dict) and "error" in result:
                print(f"ERROR: {result['error']}")
                scores_errors += row_count
            else:
                scores_inserted += row_count
                print("OK")
        except Exception as e:
            print(f"FAILED: {e}")
            scores_errors += row_count

        time.sleep(0.3)

    print(f"\nScores: {scores_inserted} sent, {scores_errors} errored.\n")

    # ---- Verification ----
    print("=" * 50)
    print("VERIFICATION")
    print("=" * 50)

    try:
        result = run_query("SELECT COUNT(*) AS city_count FROM cities;")
        city_count = result[0]["city_count"] if result else "unknown"
        print(f"Total cities in DB:       {city_count}")
    except Exception as e:
        print(f"Could not count cities: {e}")

    try:
        result = run_query("SELECT COUNT(*) AS score_count FROM city_scores;")
        score_count = result[0]["score_count"] if result else "unknown"
        print(f"Total scores in DB:       {score_count}")
    except Exception as e:
        print(f"Could not count scores: {e}")

    try:
        result = run_query(
            "SELECT COUNT(DISTINCT city_id) AS cities_with_scores FROM city_scores;"
        )
        cwith = result[0]["cities_with_scores"] if result else "unknown"
        print(f"Cities with scores:       {cwith}")
    except Exception as e:
        print(f"Could not count cities with scores: {e}")

    print("\nDone.")


if __name__ == "__main__":
    main()
