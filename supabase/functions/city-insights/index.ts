import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { OpenAI } from "https://deno.land/x/openai@v4.38.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface CityInsightsRow {
  id: string;
  city_id: string;
  known_for: string[];
  concerns: string[];
  generated_at: string;
}

interface CityRow {
  id: string;
  name: string;
  full_name: string;
  country: string;
  continent: string;
  summary: string | null;
}

// 30-day TTL for cached insights
const INSIGHTS_TTL_MS = 30 * 24 * 60 * 60 * 1000;

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { city_id } = await req.json();

    if (!city_id || typeof city_id !== "string") {
      return new Response(
        JSON.stringify({ error: "city_id is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Initialize Supabase client with service role for writes
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // ------------------------------------------------------------------
    // 1. Check for cached insights (< 30 days old)
    // ------------------------------------------------------------------
    const { data: cached, error: cacheError } = await supabase
      .from("city_insights")
      .select("*")
      .eq("city_id", city_id)
      .maybeSingle();

    if (cacheError) {
      console.error("Cache lookup error:", cacheError);
    }

    if (cached) {
      const generatedAt = new Date(cached.generated_at).getTime();
      const age = Date.now() - generatedAt;

      if (age < INSIGHTS_TTL_MS) {
        // Cache hit — return existing data
        return new Response(
          JSON.stringify({
            city_id: cached.city_id,
            known_for: cached.known_for,
            concerns: cached.concerns,
            generated_at: cached.generated_at,
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }

    // ------------------------------------------------------------------
    // 2. Fetch city details for GPT prompt context
    // ------------------------------------------------------------------
    const { data: city, error: cityError } = await supabase
      .from("cities")
      .select("id, name, full_name, country, continent, summary")
      .eq("id", city_id)
      .single();

    if (cityError || !city) {
      return new Response(
        JSON.stringify({ error: `City not found: ${city_id}` }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const typedCity = city as CityRow;

    // Also fetch the city's score categories for richer context
    const { data: scores } = await supabase
      .from("city_scores")
      .select("category, score")
      .eq("city_id", city_id);

    const scoreContext = scores
      ? scores.map((s: { category: string; score: number }) => `${s.category}: ${s.score}/10`).join(", ")
      : "No scores available";

    // ------------------------------------------------------------------
    // 3. Generate insights via GPT
    // ------------------------------------------------------------------
    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openaiKey) {
      return new Response(
        JSON.stringify({ error: "OpenAI API key not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const openai = new OpenAI({ apiKey: openaiKey });

    const prompt = `You are a knowledgeable travel advisor. For the city described below, provide two lists:

1. "known_for": 4-5 things this city is most known for among travelers and residents. Each item should be a concise phrase (3-8 words). Focus on distinctive, specific qualities — not generic statements. Examples: "World-class street food scene", "Vibrant electronic music nightlife", "Affordable beachfront living".

2. "concerns": 3-4 common concerns that travelers or potential residents should be aware of. Each item should be a concise phrase (3-8 words). Be honest but not alarmist. Examples: "High cost of living", "Air quality challenges", "Language barrier for newcomers".

City: ${typedCity.full_name}
Country: ${typedCity.country}
Continent: ${typedCity.continent}
${typedCity.summary ? `Summary: ${typedCity.summary}` : ""}
Scores: ${scoreContext}

Respond ONLY with valid JSON in this exact format:
{
  "known_for": ["item1", "item2", "item3", "item4"],
  "concerns": ["item1", "item2", "item3"]
}`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.7,
      max_tokens: 500,
      response_format: { type: "json_object" },
    });

    const rawContent = completion.choices[0]?.message?.content ?? "{}";
    let parsed: { known_for?: string[]; concerns?: string[] };

    try {
      parsed = JSON.parse(rawContent);
    } catch {
      console.error("Failed to parse GPT response:", rawContent);
      return new Response(
        JSON.stringify({ error: "Failed to parse AI response" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const knownFor = parsed.known_for ?? [];
    const concerns = parsed.concerns ?? [];

    // ------------------------------------------------------------------
    // 4. Upsert into city_insights table
    // ------------------------------------------------------------------
    const now = new Date().toISOString();

    const { error: upsertError } = await supabase
      .from("city_insights")
      .upsert(
        {
          city_id,
          known_for: knownFor,
          concerns: concerns,
          generated_at: now,
        },
        { onConflict: "city_id" }
      );

    if (upsertError) {
      console.error("Upsert error:", upsertError);
      // Still return the generated data even if caching fails
    }

    // ------------------------------------------------------------------
    // 5. Return response
    // ------------------------------------------------------------------
    return new Response(
      JSON.stringify({
        city_id,
        known_for: knownFor,
        concerns: concerns,
        generated_at: now,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({ error: error.message ?? "Unknown error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
