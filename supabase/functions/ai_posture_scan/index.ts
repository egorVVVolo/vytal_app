import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const VSEGPT_API_KEY = Deno.env.get("VSEGPT_API_KEY") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Get the Auth Header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Initialize Supabase client to check auth and quotas
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    // 3. Get User ID
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 4. Parse request body (expecting base64 image)
    const body = await req.json();
    const { image_base64 } = body;

    if (!image_base64) {
       return new Response(JSON.stringify({ error: "Missing image_base64 in request body" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 5. Check Quota (1 scan per week for free users)
    const { data: profile, error: profileError } = await supabaseClient
      .from('users')
      .select('is_pro')
      .eq('id', user.id)
      .single();

    if (profileError) {
       return new Response(JSON.stringify({ error: "Failed to fetch user profile" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const isPro = profile?.is_pro || false;

    if (!isPro) {
      // Check last scan date
      const oneWeekAgo = new Date();
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

      const { count, error: countError } = await supabaseClient
        .from('posture_scans')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', user.id)
        .gte('created_at', oneWeekAgo.toISOString());

      if (countError) {
          return new Response(JSON.stringify({ error: "Failed to check quota" }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
      }

      if (count && count >= 1) {
         return new Response(JSON.stringify({ error: "Quota exceeded. Free users are limited to 1 scan per week. Upgrade to Pro for unlimited scans." }), {
            status: 429,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
      }
    }


    // 6. Call VseGPT API
    if (!VSEGPT_API_KEY) {
        return new Response(JSON.stringify({ error: "VSEGPT API key not configured" }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }

    const vsegptPayload = {
      model: "gpt-4o-mini", // or the specific vision model you use
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "Analyze this image for posture. Return a JSON with the following structure: { overallScore: number, kyphosisScore: number, lordosisScore: number, neckScore: number, lostHeight: number, advice: string }",
            },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${image_base64}`,
              },
            },
          ],
        },
      ],
      response_format: { type: "json_object" }
    };

    const vsegptResponse = await fetch("https://api.vsegpt.ru/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${VSEGPT_API_KEY}`,
      },
      body: JSON.stringify(vsegptPayload),
    });

    if (!vsegptResponse.ok) {
       const errorText = await vsegptResponse.text();
       console.error("VseGPT API Error:", errorText);
       return new Response(JSON.stringify({ error: "Failed to process image via AI" }), {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }

    const vsegptData = await vsegptResponse.json();
    const aiResultString = vsegptData.choices[0].message.content;

    let aiResultJson;
    try {
        aiResultJson = JSON.parse(aiResultString);
    } catch (e) {
         return new Response(JSON.stringify({ error: "AI returned invalid JSON" }), {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }

    // 7. Initialize Supabase Admin Client (Service Role Key) to bypass RLS and insert the scan record
    // This is CRITICAL to enforce quotas: we MUST log the scan so the user cannot infinitely call the API without spending quota
    const supabaseAdminClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { error: insertError } = await supabaseAdminClient
        .from('posture_scans')
        .insert({
            user_id: user.id,
            overall_score: aiResultJson.overallScore,
            kyphosis_score: aiResultJson.kyphosisScore,
            lordosis_score: aiResultJson.lordosisScore,
            neck_score: aiResultJson.neckScore,
            lost_height: aiResultJson.lostHeight,
            advice: aiResultJson.advice,
        });

    if (insertError) {
         console.error("Failed to save scan record:", insertError);
         // Even if saving fails, we might still return the result, but we log the error
         // Ideally, you'd want a more robust transaction/retry system here for production
    }

    // 8. Return the result back to the client
    return new Response(JSON.stringify(aiResultJson), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("Unhandled Edge Function Error:", error);
    return new Response(JSON.stringify({ error: "Internal Server Error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
