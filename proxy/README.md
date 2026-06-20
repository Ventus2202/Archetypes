# Chatbot proxy (free — Cloudflare Workers AI)

Thin backend that holds your Cloudflare credentials and relays chat-completions
to **Workers AI** for the in-app assistant. Workers AI runs an open model on
Cloudflare's free tier, so the chatbot is free (no Anthropic key, no payment).
The tool-use loop runs on the device and only minimal tool results (names, MBTI
types, scores) reach the model.

## What you need (all free, no credit card)

- A Cloudflare account.
- Your **Account ID** (Cloudflare dashboard → right sidebar).
- An **API token** with the `Workers AI` → `Read` permission
  (dashboard → My Profile → API Tokens → Create Token).

## Deploy (Cloudflare Workers)

```sh
npm i -g wrangler
wrangler login
wrangler init archetypes-proxy   # or add cloudflare-worker.js to an existing project
wrangler secret put CF_ACCOUNT_ID
wrangler secret put CF_API_TOKEN
wrangler secret put APP_TOKEN     # optional but recommended
wrangler deploy
```

Use `cloudflare-worker.js` as the worker entry point. After deploy you get a URL
like `https://archetypes-proxy.<account>.workers.dev`.

> Alternatively, bind Workers AI directly (`[ai] binding = "AI"` in
> `wrangler.toml`) and call `env.AI.run(...)` to avoid the API token — but the
> OpenAI-compatible REST path used here has a stable, well-documented tool
> format, which is why the relay uses it.

## Point the app at it

```sh
flutter run --dart-define=CHAT_PROXY_URL=https://archetypes-proxy.<account>.workers.dev
```

(See `kChatProxyUrl` in `lib/presentation/providers/chat_provider.dart`.)

## Notes

- **Model:** the app sends `@hf/nousresearch/hermes-2-pro-mistral-7b` (built for
  function calling, cheap on the free tier). Swap it in `ChatClient.model`
  (`lib/data/chat/chat_client.dart`) — e.g.
  `@cf/meta/llama-3.3-70b-instruct-fp8-fast` for higher quality.
- **Free tier:** Workers AI has a daily allocation (Neurons). Plenty for
  personal use; a widely shared app can exhaust it — set `APP_TOKEN` and/or a
  per-IP rate limit so a leaked URL can't drain your quota.
- **Auth:** the app does not yet send `x-app-token`; add it in `ChatClient` when
  you enable `APP_TOKEN`.
- **Privacy:** profile data stays on device; only tool results travel to the model.
- **Quality:** small open models are weaker than frontier models, but the tools
  do the heavy computation — the model only picks a tool and narrates.
