// Supabase Edge Function: trip-plan
// Receives a JSON payload from the Flutter app, builds a prompt,
// calls Google Gemini, and returns a strict-JSON trip plan.
//
// Deploy: supabase functions deploy trip-plan
// Secrets: supabase secrets set GEMINI_API_KEY=<your-key>

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY') ?? '';
const GEMINI_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

const SYSTEM_PROMPT = `You are a trip planning engine. You MUST respond with VALID JSON ONLY.
DO NOT include markdown, code fences, commentary, or any extra text.

Output must follow this exact JSON schema (no extra top-level keys):
{
  "nama_tempat": "string",
  "deskripsi": "string",
  "estimasi_biaya": 12345,
  "days": [
    {
      "date": "YYYY-MM-DD",
      "itinerary": [
        {
          "waktu_mulai": "HH:MM",
          "waktu_selesai": "HH:MM",
          "aktivitas": "string"
        }
      ]
    }
  ],
  "assumptions": ["string"],
  "warnings": ["string"]
}

Rules:
- JSON must be strictly parseable (double quotes, no trailing commas).
- "estimasi_biaya" MUST be an integer >= 0 (total estimate for the whole trip).
- "days" length MUST match the requested number of days (min 1, max 7).
- Each itinerary item must have waktu_mulai < waktu_selesai (24h format).
- Avoid unsafe or illegal suggestions.
- If user preferences are missing, still output JSON and add notes in "assumptions" or "warnings".
- Use concise, realistic activities with clear timing.`;

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    const body = await req.json();
    const { destination, start_date, days, budget_total, preferences } = body;

    if (!destination || !start_date || !days) {
      return new Response(
        JSON.stringify({ error: 'destination, start_date, and days are required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const userMessage = JSON.stringify({
      destination,
      start_date,
      days,
      budget_total: budget_total ?? 0,
      preferences: preferences ?? {},
    });

    const geminiBody = {
      contents: [
        {
          role: 'user',
          parts: [{ text: `${SYSTEM_PROMPT}\n\nPlan this trip:\n${userMessage}` }],
        },
      ],
      generationConfig: {
        temperature: 0.4,
        maxOutputTokens: 4096,
      },
    };

    const geminiRes = await fetch(
      `${GEMINI_ENDPOINT}?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(geminiBody),
      },
    );

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      return new Response(
        JSON.stringify({ error: `Gemini error: ${geminiRes.status}`, detail: errText }),
        { status: 502, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const geminiData = await geminiRes.json();
    const rawText: string =
      geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

    // Strip accidental markdown fences
    const cleaned = rawText
      .replace(/^```json\s*/i, '')
      .replace(/^```\s*/i, '')
      .replace(/\s*```$/i, '')
      .trim();

    const parsed = JSON.parse(cleaned);

    return new Response(JSON.stringify(parsed), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
