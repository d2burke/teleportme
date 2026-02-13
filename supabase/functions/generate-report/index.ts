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

    const { current_city_id, start_type, title, preferences }: RequestBody = await req.json();

    const effectiveStartType = start_type ?? "city_i_love";
    const effectiveTitle = title ?? "Untitled Exploration";
    const hasBaselineCity = !!current_city_id;

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
        let totalWeight = 0;
        let weightedScore = 0;

        for (const pref of prefWeights) {
          const cityVal = cityScores[pref.category] ?? 5;
          // Higher preference weight = user cares more about this category
          // Score = how well the city meets the preference (0-10 scale)
          const prefNorm = pref.weight / 10; // normalize to 0-1
          const cityNorm = cityVal / 10;
          weightedScore += prefNorm * cityNorm * 100;
          totalWeight += prefNorm;
        }

        // Light bonus for categories not directly controlled by user
        const bonusCategories = ["Internet Access", "Tolerance"];
        for (const cat of bonusCategories) {
          const val = cityScores[cat] ?? 5;
          weightedScore += (val / 10) * 10; // light bonus
          totalWeight += 0.1;
        }

        const matchScore =
          totalWeight > 0
            ? Math.round(Math.min(99, Math.max(40, weightedScore / totalWeight)))
            : 50;

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

    const gptPrompt = `You are a city relocation advisor. ${baselinePart}

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
      const { data: exploration } = await supabase
        .from("explorations")
        .insert({
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
        })
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
