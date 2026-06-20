// Thin relay between the Archetypes app and Cloudflare Workers AI.
// It injects the Cloudflare credentials (which the app must never hold) and
// forwards the request to Workers AI's OpenAI-compatible chat-completions
// endpoint. Workers AI runs an open model on Cloudflare's free tier, so the
// chatbot costs nothing.
//
// Vars / secrets (set with `wrangler secret put` / in the dashboard):
//   CF_ACCOUNT_ID  (required) - your Cloudflare account id
//   CF_API_TOKEN   (required) - API token with "Workers AI: Read" permission
//   APP_TOKEN      (optional) - if set, requests must send a matching
//                               `x-app-token` header. Recommended so a leaked
//                               URL can't drain your free quota.

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }
    if (env.APP_TOKEN && request.headers.get('x-app-token') !== env.APP_TOKEN) {
      return new Response('Unauthorized', { status: 401 });
    }

    const body = await request.text();
    const url =
      `https://api.cloudflare.com/client/v4/accounts/${env.CF_ACCOUNT_ID}` +
      `/ai/v1/chat/completions`;

    const upstream = await fetch(url, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${env.CF_API_TOKEN}`,
      },
      body, // { model, messages, tools, max_tokens } — OpenAI shape, forwarded as-is
    });

    return new Response(upstream.body, {
      status: upstream.status,
      headers: { 'content-type': 'application/json' },
    });
  },
};
