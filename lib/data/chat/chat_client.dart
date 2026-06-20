import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the chat proxy (a Cloudflare Worker that injects the Cloudflare
/// credentials and forwards to Workers AI's OpenAI-compatible
/// `/ai/v1/chat/completions` endpoint). The app holds no credentials. Workers
/// AI runs an open model on Cloudflare's free tier, so the chatbot is free.
class ChatClient {
  ChatClient({required this.proxyUrl, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  /// Cloudflare Workers AI model with function-calling support. Swappable —
  /// hermes-2-pro is purpose-built for tools and cheap on the free tier;
  /// `@cf/meta/llama-3.3-70b-instruct-fp8-fast` gives higher quality.
  static const String model = '@hf/nousresearch/hermes-2-pro-mistral-7b';

  final String proxyUrl;
  final http.Client _http;

  bool get isConfigured => proxyUrl.isNotEmpty;

  /// One OpenAI-style chat-completions call through the proxy. Returns the
  /// decoded response (`choices[0].message`, `finish_reason`, …).
  Future<Map<String, dynamic>> complete({
    required List<Map<String, dynamic>> messages,
    required List<Map<String, dynamic>> tools,
    int maxTokens = 1024,
  }) async {
    if (!isConfigured) {
      throw StateError('Chat proxy URL not configured');
    }
    final resp = await _http.post(
      Uri.parse(proxyUrl),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'max_tokens': maxTokens,
        'messages': messages,
        'tools': tools,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Proxy error ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
