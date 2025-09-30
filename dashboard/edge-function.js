import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const path = url.pathname;

    if (path === '/' || path === '/dashboard') {
      const html = await Deno.readTextFile('./index.html');
      return new Response(html, {
        headers: {
          ...corsHeaders,
          'Content-Type': 'text/html',
        },
      });
    }

    if (path === '/api/dashboard-data') {
      const dashboardData = {
        monthly_trends: [],
        quarterly_trends: [],
        top_products: [],
        top_customers: []
      };

      return new Response(JSON.stringify(dashboardData), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      });
    }

    if (path === '/health') {
      return new Response(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      });
    }

    return new Response('Not Found', { 
      status: 404,
      headers: corsHeaders 
    });

  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
      status: 500,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    });
  }
});
