import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { OpenAI } from "https://deno.land/x/openai@v4.38.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  current_city_id?: string;       // Optional — null for vibes/words start types
  start_type?: string;            // "city_i_love" | "vibes" | "my_words" (default: "city_i_love")
  title?: string;                 // Exploration title (default: "Untitled Exploration")
  vibe_tags?: string[];           // Vibe tag UUIDs for vibes start type
  user_vibe_tags?: string[];      // Saved profile vibes — secondary signal for all start types
  compass_vibes?: Record<string, number>;  // Signal weights from Trip Compass (e.g., { "climate": 3, "food": 2 })
  compass_constraints?: {                   // Trip constraints from Compass flow
    travel_distance?: "short" | "medium" | "far";
    safety_comfort?: "adventurous" | "street_smart" | "relaxed";
    budget_vibe?: "affordable" | "moderate" | "splurge";
  };
  preferences: {
    cost: number;
    climate: number;
    culture: number;
    job_market: number;
    safety?: number;
    commute?: number;
    healthcare?: number;
  };
}

interface CityVibeTagRow {
  city_id: string;
  vibe_tag_id: string;
  strength: number;
}

interface VibeTagNameRow {
  id: string;
  name: string;
}

interface CityRow {
  id: string;
  name: string;
  full_name: string;
  country: string;
  image_url: string | null;
}

interface CityScoreRow {
  city_id: string;
  category: string;
  score: number;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY")! });

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get the user from the auth header
    const authHeader = req.headers.get("Authorization");
    let userId: string | null = null;
    if (authHeader) {
      const anonClient = createClient(
        supabaseUrl,
        Deno.env.get("SUPABASE_ANON_KEY")!
      );
      const {
        data: { user },
      } = await anonClient.auth.getUser(authHeader.replace("Bearer ", ""));
      userId = user?.id ?? null;
    }

    const { current_city_id, start_type, title, preferences, vibe_tags, user_vibe_tags, compass_vibes, compass_constraints }: RequestBody = await req.json();

    const effectiveStartType = start_type ?? "city_i_love";
    const effectiveTitle = title ?? "Untitled Exploration";
    const hasBaselineCity = !!current_city_id;
    const isVibesMode = effectiveStartType === "vibes" && vibe_tags && vibe_tags.length > 0;
    const hasUserVibes = user_vibe_tags && user_vibe_tags.length > 0;
    const isCompassMode = compass_vibes && Object.keys(compass_vibes).length > 0;

    // ------------------------------------------------------------------
    // 1. Fetch current city + its scores (only if baseline city provided)
    // ------------------------------------------------------------------
    let currentCity: CityRow | null = null;
    const currentScores: Record<string, number> = {};

    if (hasBaselineCity) {
      const { data: cityData } = await supabase
        .from("cities")
        .select("id, name, full_name, country, image_url")
        .eq("id", current_city_id)
        .single<CityRow>();

      if (!cityData) {
        return new Response(
          JSON.stringify({ error: "Current city not found" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      currentCity = cityData;

      const { data: currentScoresRaw } = await supabase
        .from("city_scores")
        .select("category, score")
        .eq("city_id", current_city_id);

      for (const s of (currentScoresRaw ?? []) as CityScoreRow[]) {
        currentScores[s.category] = s.score;
      }
    }

    // ------------------------------------------------------------------
    // 2. Fetch all candidate cities + scores
    // ------------------------------------------------------------------
    let cityQuery = supabase
      .from("cities")
      .select("id, name, full_name, country, image_url");

    // Exclude baseline city from candidates if one was provided
    if (hasBaselineCity) {
      cityQuery = cityQuery.neq("id", current_city_id!);
    }

    const { data: allCities } = await cityQuery;

    const { data: allScoresRaw } = await supabase
      .from("city_scores")
      .select("city_id, category, score");

    // Build a scores map: city_id -> { category -> score }
    const scoresMap: Record<string, Record<string, number>> = {};
    for (const s of (allScoresRaw ?? []) as CityScoreRow[]) {
      if (!scoresMap[s.city_id]) scoresMap[s.city_id] = {};
      scoresMap[s.city_id][s.category] = s.score;
    }

    // ------------------------------------------------------------------
    // 2b. Fetch vibe data if needed
    // ------------------------------------------------------------------
    // Compute vibe scores for vibes-first mode or secondary profile vibes
    const vibeScoreMap: Record<string, number> = {};
    const userVibeScoreMap: Record<string, number> = {};
    let vibeNameList: string[] = [];
    let userVibeNameList: string[] = [];

    if (isVibesMode) {
      const { data: vibeTagRows } = await supabase
        .from("city_vibe_tags")
        .select("city_id, vibe_tag_id, strength")
        .in("vibe_tag_id", vibe_tags!);

      const cityVibeHits: Record<string, number[]> = {};
      for (const row of (vibeTagRows ?? []) as CityVibeTagRow[]) {
        if (!cityVibeHits[row.city_id]) cityVibeHits[row.city_id] = [];
        cityVibeHits[row.city_id].push(row.strength);
      }
      for (const [cityId, strengths] of Object.entries(cityVibeHits)) {
        const avgStrength = strengths.reduce((a, b) => a + b, 0) / strengths.length;
        const coverage = strengths.length / vibe_tags!.length;
        vibeScoreMap[cityId] = Math.round(avgStrength * coverage * 100);
      }

      const { data: vibeTagNames } = await supabase
        .from("vibe_tags")
        .select("id, name")
        .in("id", vibe_tags!);
      vibeNameList = ((vibeTagNames ?? []) as VibeTagNameRow[]).map(t => t.name);
    }

    if (hasUserVibes) {
      const { data: userVibeRows } = await supabase
        .from("city_vibe_tags")
        .select("city_id, vibe_tag_id, strength")
        .in("vibe_tag_id", user_vibe_tags!);

      const cityUserVibeHits: Record<string, number[]> = {};
      for (const row of (userVibeRows ?? []) as CityVibeTagRow[]) {
        if (!cityUserVibeHits[row.city_id]) cityUserVibeHits[row.city_id] = [];
        cityUserVibeHits[row.city_id].push(row.strength);
      }
      for (const [cityId, strengths] of Object.entries(cityUserVibeHits)) {
        const avgStrength = strengths.reduce((a, b) => a + b, 0) / strengths.length;
        const coverage = strengths.length / user_vibe_tags!.length;
        userVibeScoreMap[cityId] = Math.round(avgStrength * coverage * 100);
      }

      if (!isVibesMode) {
        const { data: userVibeTagNames } = await supabase
          .from("vibe_tags")
          .select("id, name")
          .in("id", user_vibe_tags!);
        userVibeNameList = ((userVibeTagNames ?? []) as VibeTagNameRow[]).map(t => t.name);
      }
    }

    // ------------------------------------------------------------------
    // 2c. Fetch vibe tag data for compass mode (Signal→VibeTags mapping)
    // ------------------------------------------------------------------
    // Maps each compass signal to relevant vibe tags for blended scoring.
    // This solves the signal collision problem where culture/food/nightlife
    // all mapped to "Leisure & Culture" (Berlin dominates everything).
    const signalVibeTagMap: Record<string, string[]> = {
      climate: ["Beach Life", "Outdoorsy"],
      cost: ["Affordable", "Digital Nomad"],
      culture: ["Arts & Music", "Historic", "Bohemian", "Cosmopolitan"],
      safety: ["Family Friendly", "LGBTQ+ Friendly"],
      career: ["Startup Hub", "Student Friendly"],
      nature: ["Outdoorsy", "Beach Life", "Eco-Conscious"],
      food: ["Foodie", "Coffee Culture"],           // vibe-only, no category score
      nightlife: ["Nightlife", "Fast-Paced"],       // vibe-only, no category score
    };

    // Updated category map — food and nightlife NO LONGER map to "Leisure & Culture"
    const signalCategoryMap: Record<string, string | null> = {
      climate: "Environmental Quality",
      cost: "Cost of Living",
      culture: "Leisure & Culture",
      safety: "Safety",
      career: "Economy",
      nature: "Outdoors",
      food: null,        // scored purely via vibe tags
      nightlife: null,   // scored purely via vibe tags
    };

    // Build per-city vibe tag strengths for compass mode scoring
    // cityVibeStrengths: { city_id -> { tagName -> strength } }
    const cityVibeStrengths: Record<string, Record<string, number>> = {};

    if (isCompassMode) {
      // Collect all unique vibe tag names needed for active signals
      const activeSignalNames = Object.entries(compass_vibes!)
        .filter(([_, w]) => w > 0)
        .map(([signal]) => signal);
      const neededTagNames = new Set<string>();
      for (const signal of activeSignalNames) {
        const tags = signalVibeTagMap[signal] ?? [];
        for (const tag of tags) neededTagNames.add(tag);
      }

      if (neededTagNames.size > 0) {
        // Look up vibe tag IDs by name
        const { data: tagNameRows } = await supabase
          .from("vibe_tags")
          .select("id, name")
          .in("name", Array.from(neededTagNames));

        const tagIdToName: Record<string, string> = {};
        const tagIds: string[] = [];
        for (const row of (tagNameRows ?? []) as VibeTagNameRow[]) {
          tagIdToName[row.id] = row.name;
          tagIds.push(row.id);
        }

        if (tagIds.length > 0) {
          // Fetch all city_vibe_tags for these tag IDs in one query
          const { data: compassVibeRows } = await supabase
            .from("city_vibe_tags")
            .select("city_id, vibe_tag_id, strength")
            .in("vibe_tag_id", tagIds);

          for (const row of (compassVibeRows ?? []) as CityVibeTagRow[]) {
            const tagName = tagIdToName[row.vibe_tag_id];
            if (!tagName) continue;
            if (!cityVibeStrengths[row.city_id]) cityVibeStrengths[row.city_id] = {};
            cityVibeStrengths[row.city_id][tagName] = row.strength;
          }
        }
      }
    }

    // ------------------------------------------------------------------
    // 3. Algorithmic scoring — rank cities by preference alignment
    // ------------------------------------------------------------------

    // Build preference weights — all 7 user-facing preferences are first-class
    const prefWeights = [
      { category: "Cost of Living", weight: preferences.cost },
      { category: "Environmental Quality", weight: preferences.climate },
      { category: "Leisure & Culture", weight: preferences.culture },
      { category: "Economy", weight: preferences.job_market },
      { category: "Safety", weight: preferences.safety ?? 5 },
      { category: "Commute", weight: preferences.commute ?? 5 },
      { category: "Healthcare", weight: preferences.healthcare ?? 5 },
    ];

    type ScoredCity = {
      city: CityRow;
      scores: Record<string, number>;
      matchScore: number;
    };

    const scoredCities: ScoredCity[] = (allCities ?? [])
      .map((city: CityRow) => {
        const cityScores = scoresMap[city.id] ?? {};

        let matchScore: number;

        // -------------------------------------------------------
        // COMPASS MODE: Blended signal weights (category + vibe tags)
        // + multiplicative constraint modifiers
        // -------------------------------------------------------
        if (isCompassMode) {
          // Blended score: for each signal, combine category score + vibe tag strength
          let blendedWeightedScore = 0;
          let totalSignalWeight = 0;
          const cityVibeTags = cityVibeStrengths[city.id] ?? {};

          for (const [signal, weight] of Object.entries(compass_vibes!)) {
            if (weight <= 0) continue;

            const category = signalCategoryMap[signal];
            const mappedTags = signalVibeTagMap[signal] ?? [];

            // Category component (normalized 0-1)
            const hasCategoryScore = category != null;
            const categoryScore = hasCategoryScore
              ? (cityScores[category!] ?? 5) / 10
              : 0;

            // Vibe tag component: average strength of matching tags (0-1)
            // Uses coverage-weighted scoring: cities must match a meaningful
            // proportion of the signal's vibe tags to score well.
            let vibeTagScore = 0;
            let vibeTagCoverage = 0; // fraction of mapped tags the city actually has
            const hasVibeTags = mappedTags.length > 0;
            if (hasVibeTags) {
              const tagStrengths = mappedTags
                .map(tag => cityVibeTags[tag])
                .filter((s): s is number => s != null);
              if (tagStrengths.length > 0) {
                vibeTagScore = tagStrengths.reduce((a, b) => a + b, 0) / tagStrengths.length;
                vibeTagCoverage = tagStrengths.length / mappedTags.length;
              }
              // Cities with NO matching vibe tags get vibeTagScore=0, coverage=0.
              // Berlin has no "Beach Life" tag → vibeTagScore = 0 for climate signal.
            }

            // Blend category + vibe tag scores
            // Key insight: vibe tags are the primary differentiator. Category
            // scores are too coarse (e.g., "Environmental Quality" doesn't
            // distinguish beach cities from Nordic countries). So vibe tags
            // get 70% weight, and cities with ZERO matching vibe tags get
            // their category score heavily discounted.
            let blendedScore: number;
            if (hasCategoryScore && hasVibeTags) {
              if (vibeTagCoverage === 0) {
                // City has NONE of the signal's vibe tags → category score
                // alone is unreliable. Discount heavily (×0.3).
                // Helsinki has high Environmental Quality but no Beach Life
                // or Outdoorsy → shouldn't score well on "climate" signal.
                blendedScore = categoryScore * 0.3;
              } else {
                // City has at least some matching vibe tags → 30/70 blend
                // weighted by coverage (matching more tags = higher score)
                blendedScore = categoryScore * 0.3 + vibeTagScore * vibeTagCoverage * 0.7;
              }
            } else if (hasVibeTags) {
              // Vibe-only signals (food, nightlife): scored purely from tags
              // Also factor in coverage — matching both tags > matching one
              blendedScore = vibeTagScore * (0.5 + vibeTagCoverage * 0.5);
            } else {
              // Category-only (shouldn't happen with current map, but safe fallback)
              blendedScore = categoryScore;
            }

            blendedWeightedScore += blendedScore * weight;
            totalSignalWeight += weight;
          }

          const vibeScore = totalSignalWeight > 0
            ? (blendedWeightedScore / totalSignalWeight) * 100
            : 50;

          // Constraint modifiers — multiplicative penalties instead of soft additive bonuses
          let constraintMultiplier = 1.0;

          if (compass_constraints) {
            // Safety comfort — multiplicative penalty for unsafe cities
            if (compass_constraints.safety_comfort) {
              const safetyVal = cityScores["Safety"] ?? 5;
              const thresholds: Record<string, number> = { adventurous: 0, street_smart: 5, relaxed: 7 };
              const threshold = thresholds[compass_constraints.safety_comfort] ?? 5;
              if (safetyVal < threshold) {
                // Penalty scales with how far below threshold: 0.7 at worst
                constraintMultiplier *= 0.7 + (safetyVal / threshold) * 0.3;
              }
            }

            // Budget vibe — multiplicative penalty for expensive cities when affordable
            if (compass_constraints.budget_vibe) {
              const costVal = cityScores["Cost of Living"] ?? 5;
              switch (compass_constraints.budget_vibe) {
                case "affordable":
                  if (costVal < 5) {
                    // Expensive city + affordable budget = penalty
                    constraintMultiplier *= 0.75 + (costVal / 20);
                  }
                  break;
                case "moderate":
                  if (costVal < 3) {
                    // Very expensive city + moderate budget = mild penalty
                    constraintMultiplier *= 0.85 + (costVal / 20);
                  }
                  break;
                case "splurge":
                  // No penalty — user is fine spending
                  break;
              }
            }

            // Travel distance — no penalty for now (no user location data)
            // Future: use user's baseline city lat/long for distance filtering
          }

          matchScore = Math.round(Math.min(99, Math.max(20, vibeScore * constraintMultiplier)));

        // -------------------------------------------------------
        // LEGACY MODE: Preference weights + optional vibe blending
        // -------------------------------------------------------
        } else {
          let totalWeight = 0;
          let weightedScore = 0;

          for (const pref of prefWeights) {
            const cityVal = cityScores[pref.category] ?? 5;
            const prefNorm = pref.weight / 10;
            const cityNorm = cityVal / 10;
            weightedScore += prefNorm * cityNorm * 100;
            totalWeight += prefNorm;
          }

          const bonusCategories = ["Internet Access", "Tolerance"];
          for (const cat of bonusCategories) {
            const val = cityScores[cat] ?? 5;
            weightedScore += (val / 10) * 10;
            totalWeight += 0.1;
          }

          const prefScore =
            totalWeight > 0
              ? Math.round(Math.min(99, Math.max(40, weightedScore / totalWeight)))
              : 50;

          if (isVibesMode) {
            const vibeScore = vibeScoreMap[city.id] ?? 0;
            matchScore = Math.round(Math.min(99, Math.max(40, vibeScore * 0.6 + prefScore * 0.4)));
          } else if (hasUserVibes) {
            const vibeAffinity = userVibeScoreMap[city.id] ?? 0;
            matchScore = Math.round(Math.min(99, Math.max(40, prefScore + (vibeAffinity / 100) * 5)));
          } else {
            matchScore = prefScore;
          }
        }

        return { city, scores: cityScores, matchScore };
      })
      .sort((a: ScoredCity, b: ScoredCity) => b.matchScore - a.matchScore);

    // Top 5 candidates for GPT to refine
    const topCandidates = scoredCities.slice(0, 8);

    // ------------------------------------------------------------------
    // 4. GPT — refine picks and generate insights
    // ------------------------------------------------------------------
    const candidatesSummary = topCandidates
      .map(
        (c: ScoredCity) =>
          `id="${c.city.id}" — ${c.city.name} (${c.city.country}) — algo score: ${c.matchScore}, scores: Cost=${c.scores["Cost of Living"] ?? "?"}, Climate=${c.scores["Environmental Quality"] ?? "?"}, Culture=${c.scores["Leisure & Culture"] ?? "?"}, Jobs=${c.scores["Economy"] ?? "?"}, Safety=${c.scores["Safety"] ?? "?"}, Transit=${c.scores["Commute"] ?? "?"}, Health=${c.scores["Healthcare"] ?? "?"}`
      )
      .join("\n");

    const validIds = topCandidates.map((c: ScoredCity) => c.city.id);

    const baselinePart = hasBaselineCity
      ? `A user currently lives in ${currentCity!.name}, ${currentCity!.country}.\n\nCurrent city scores: ${JSON.stringify(currentScores)}`
      : `A user is exploring cities to visit or relocate to. They have not specified a current city.`;

    const vibesPart = isVibesMode
      ? `\n\nThe user specifically selected these vibes/lifestyle tags: ${vibeNameList.join(", ")}. Strongly prioritize cities that match these vibes in your reasoning and insights.\n`
      : hasUserVibes
        ? `\n\nThe user generally prefers cities with these vibes: ${userVibeNameList.join(", ")}. Give slight preference to cities matching these vibes, but prioritize the primary criteria.\n`
        : "";

    // Build compass context for GPT when in compass mode
    let compassPart = "";
    if (isCompassMode) {
      const signalLabels: Record<string, string> = {
        climate: "Climate", cost: "Affordability", culture: "Culture",
        safety: "Safety", career: "Career", nature: "Nature",
        food: "Food", nightlife: "Nightlife",
      };
      const intensityLabels = ["off", "low", "medium", "high"];

      // Build rich signal descriptions that include mapped vibe tags
      const activeSignalDescriptions = Object.entries(compass_vibes!)
        .filter(([_, w]) => w > 0)
        .map(([signal, w]) => {
          const label = signalLabels[signal] ?? signal;
          const intensity = intensityLabels[w] ?? w;
          const vibeTags = signalVibeTagMap[signal] ?? [];
          const vibeContext = vibeTags.length > 0 ? ` → looking for ${vibeTags.join(", ")} cities` : "";
          return `${label} (${intensity})${vibeContext}`;
        })
        .join("; ");
      compassPart = `\n\nThe user's trip compass signals: ${activeSignalDescriptions}.`;

      if (compass_constraints) {
        const constraintParts: string[] = [];
        if (compass_constraints.travel_distance) {
          const labels: Record<string, string> = { short: "Quick hop (under 5h)", medium: "Worth a connection (5-10h)", far: "Anywhere" };
          constraintParts.push(`Travel: ${labels[compass_constraints.travel_distance] ?? compass_constraints.travel_distance}`);
        }
        if (compass_constraints.safety_comfort) {
          const labels: Record<string, string> = { adventurous: "Adventure mode", street_smart: "Street smart", relaxed: "Peace of mind" };
          constraintParts.push(`Comfort: ${labels[compass_constraints.safety_comfort] ?? compass_constraints.safety_comfort}`);
        }
        if (compass_constraints.budget_vibe) {
          const labels: Record<string, string> = { affordable: "Keep it lean", moderate: "Comfortable", splurge: "Treat ourselves" };
          constraintParts.push(`Budget: ${labels[compass_constraints.budget_vibe] ?? compass_constraints.budget_vibe}`);
        }
        if (constraintParts.length > 0) {
          compassPart += ` Their constraints: ${constraintParts.join(", ")}.`;
        }
      }
      compassPart += ` Recommend cities that match these specific signals and constraints. Explain WHY each city matches the user's particular vibes — reference the specific lifestyle qualities they're looking for.`;
    }

    const gptPrompt = isCompassMode
      ? `You are a city and travel advisor. ${baselinePart}
${compassPart}

Here are the top algorithmic candidates:
${candidatesSummary}

Pick the best 3-5 cities from the candidates. For each, write a single-sentence "ai_insight" explaining WHY this city matches the user's specific compass signals. Be personal — reference their vibes and constraints by name.

IMPORTANT: You MUST use the exact "id" values shown above for city_id. Valid IDs are: ${JSON.stringify(validIds)}

Respond with ONLY a JSON array:
[
  { "city_id": "exact-id-from-above", "ai_insight": "..." },
  ...
]

Pick 3 to 5 cities. Return valid JSON only, no markdown.`
      : `You are a city relocation advisor. ${baselinePart}
${vibesPart}
Their preferences (1-10 scale where 10 = most important):
- Affordable cost of living: ${preferences.cost}/10
- Good climate/environment: ${preferences.climate}/10
- Rich culture & leisure: ${preferences.culture}/10
- Strong job market: ${preferences.job_market}/10
- Safety: ${preferences.safety ?? 5}/10
- Public transit & commute: ${preferences.commute ?? 5}/10
- Healthcare quality: ${preferences.healthcare ?? 5}/10

Here are the top algorithmic candidates:
${candidatesSummary}

Pick the best 3-5 cities from the candidates. For each, write a single-sentence "ai_insight" explaining WHY this city is a great match given the user's specific preferences. Be specific and personal — reference their priorities.

IMPORTANT: You MUST use the exact "id" values shown above for city_id. Valid IDs are: ${JSON.stringify(validIds)}

Respond with ONLY a JSON array:
[
  { "city_id": "exact-id-from-above", "ai_insight": "..." },
  ...
]

Pick 3 to 5 cities. Return valid JSON only, no markdown.`;

    const chat = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      temperature: 0.7,
      messages: [{ role: "user", content: gptPrompt }],
    });

    let gptPicks: { city_id: string; ai_insight: string }[] = [];
    try {
      const raw = chat.choices?.[0]?.message?.content?.trim() ?? "[]";
      // Strip markdown fences if GPT wraps them
      const cleaned = raw.replace(/```json\n?/g, "").replace(/```\n?/g, "");
      const parsed = JSON.parse(cleaned);
      // Only keep picks that match valid candidate IDs
      gptPicks = parsed.filter((p: { city_id: string }) =>
        validIds.includes(p.city_id)
      );
    } catch {
      console.error("GPT response parse failed, using algorithmic picks");
    }

    // Fallback to top algorithmic picks if GPT returned nothing usable
    if (gptPicks.length === 0) {
      console.log("Using algorithmic fallback");
      gptPicks = topCandidates.slice(0, 4).map((c: ScoredCity) => ({
        city_id: c.city.id,
        ai_insight: `${c.city.name} scores well across your priorities with strong marks in the categories you care about most.`,
      }));
    }

    // ------------------------------------------------------------------
    // 5. Build the response matching iOS GenerateReportResponse
    // ------------------------------------------------------------------
    const comparisonCategories = [
      "Cost of Living",
      "Environmental Quality",
      "Leisure & Culture",
      "Economy",
      "Safety",
      "Commute",
      "Healthcare",
    ];

    const matches = gptPicks.map(
      (pick: { city_id: string; ai_insight: string }, idx: number) => {
        const scored = scoredCities.find(
          (s: ScoredCity) => s.city.id === pick.city_id
        );
        if (!scored) return null;

        const comparison: Record<
          string,
          { match_score: number; current_score: number; delta: number }
        > = {};
        for (const cat of comparisonCategories) {
          const matchVal = scored.scores[cat] ?? 5;
          const currentVal = currentScores[cat] ?? 5;
          comparison[cat] = {
            match_score: matchVal,
            current_score: currentVal,
            delta: Math.round((matchVal - currentVal) * 10) / 10,
          };
        }

        return {
          city_id: scored.city.id,
          city_name: scored.city.name,
          city_full_name: scored.city.full_name,
          city_country: scored.city.country,
          city_image_url: scored.city.image_url,
          match_percent: scored.matchScore,
          rank: idx + 1,
          comparison,
          ai_insight: pick.ai_insight,
          scores: scored.scores,
        };
      }
    ).filter(Boolean);

    // ------------------------------------------------------------------
    // 6. Save to DB — write to both explorations (new) and city_reports (legacy)
    // ------------------------------------------------------------------
    let reportId: string | null = null;
    let explorationId: string | null = null;

    if (userId) {
      // Write to new explorations table
      const explorationInsert: Record<string, unknown> = {
          user_id: userId,
          title: effectiveTitle,
          start_type: effectiveStartType,
          baseline_city_id: current_city_id ?? null,
          preferences: {
            cost: preferences.cost,
            climate: preferences.climate,
            culture: preferences.culture,
            job_market: preferences.job_market,
            safety: preferences.safety ?? 5,
            commute: preferences.commute ?? 5,
            healthcare: preferences.healthcare ?? 5,
          },
          results: matches,
          vibe_tags: vibe_tags ?? [],
      };

      // Save compass data when in compass mode
      if (isCompassMode) {
        explorationInsert.compass_vibes = compass_vibes;
        if (compass_constraints) {
          explorationInsert.compass_constraints = compass_constraints;
        }
      }

      const { data: exploration } = await supabase
        .from("explorations")
        .insert(explorationInsert)
        .select("id")
        .single();

      explorationId = exploration?.id ?? null;

      // Also write to legacy city_reports for backward compat
      const { data: report } = await supabase
        .from("city_reports")
        .insert({
          user_id: userId,
          current_city_id: current_city_id ?? null,
          preferences: {
            cost: preferences.cost,
            climate: preferences.climate,
            culture: preferences.culture,
            job_market: preferences.job_market,
            safety: preferences.safety ?? 5,
            commute: preferences.commute ?? 5,
            healthcare: preferences.healthcare ?? 5,
          },
          results: matches,
        })
        .select("id")
        .single();

      reportId = report?.id ?? null;
    }

    // ------------------------------------------------------------------
    // 7. Return response
    // ------------------------------------------------------------------
    const response = {
      report_id: reportId,
      exploration_id: explorationId,
      current_city: hasBaselineCity
        ? {
            id: currentCity!.id,
            name: currentCity!.name,
            scores: currentScores,
          }
        : null,
      matches,
    };

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("generate-report error:", error);
    return new Response(
      JSON.stringify({ error: "Report generation failed", details: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
