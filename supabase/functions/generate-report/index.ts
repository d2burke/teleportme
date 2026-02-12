import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { OpenAI } from "https://deno.land/x/openai@v4.38.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  current_city_id: string;
  preferences: {
    cost: number;
    climate: number;
    culture: number;
    job_market: number;
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

    const { current_city_id, preferences }: RequestBody = await req.json();

    // ------------------------------------------------------------------
    // 1. Fetch current city + its scores
    // ------------------------------------------------------------------
    const { data: currentCity } = await supabase
      .from("cities")
      .select("id, name, full_name, country, image_url")
      .eq("id", current_city_id)
      .single<CityRow>();

    if (!currentCity) {
      return new Response(
        JSON.stringify({ error: "Current city not found" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: currentScoresRaw } = await supabase
      .from("city_scores")
      .select("category, score")
      .eq("city_id", current_city_id);

    const currentScores: Record<string, number> = {};
    for (const s of (currentScoresRaw ?? []) as CityScoreRow[]) {
      currentScores[s.category] = s.score;
    }

    // ------------------------------------------------------------------
    // 2. Fetch all candidate cities + scores
    // ------------------------------------------------------------------
    const { data: allCities } = await supabase
      .from("cities")
      .select("id, name, full_name, country, image_url")
      .neq("id", current_city_id);

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
    const prefWeights = [
      { category: "Cost of Living", weight: preferences.cost, direction: 1 },
      {
        category: "Environmental Quality",
        weight: preferences.climate,
        direction: 1,
      },
      {
        category: "Leisure & Culture",
        weight: preferences.culture,
        direction: 1,
      },
      { category: "Economy", weight: preferences.job_market, direction: 1 },
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

        // Add bonus for categories the user didn't explicitly weight
        const bonusCategories = [
          "Safety",
          "Healthcare",
          "Commute",
          "Internet Access",
          "Tolerance",
        ];
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
          `id="${c.city.id}" — ${c.city.name} (${c.city.country}) — algo score: ${c.matchScore}, key scores: Cost=${c.scores["Cost of Living"] ?? "?"}, Climate=${c.scores["Environmental Quality"] ?? "?"}, Culture=${c.scores["Leisure & Culture"] ?? "?"}, Jobs=${c.scores["Economy"] ?? "?"}`
      )
      .join("\n");

    const validIds = topCandidates.map((c: ScoredCity) => c.city.id);

    const gptPrompt = `You are a city relocation advisor. A user currently lives in ${currentCity.name}, ${currentCity.country}.

Their preferences (1-10 scale where 10 = most important):
- Affordable cost of living: ${preferences.cost}/10
- Good climate/environment: ${preferences.climate}/10
- Rich culture & leisure: ${preferences.culture}/10
- Strong job market: ${preferences.job_market}/10

Current city scores: ${JSON.stringify(currentScores)}

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
      "Commute",
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
    // 6. Save report to DB
    // ------------------------------------------------------------------
    let reportId: string | null = null;
    if (userId) {
      const { data: report } = await supabase
        .from("city_reports")
        .insert({
          user_id: userId,
          current_city_id,
          preferences: {
            cost: preferences.cost,
            climate: preferences.climate,
            culture: preferences.culture,
            job_market: preferences.job_market,
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
      current_city: {
        id: currentCity.id,
        name: currentCity.name,
        scores: currentScores,
      },
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
