import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat/chat_client.dart';
import '../../data/chat/chat_engine.dart';
import '../../data/chat/chat_tools.dart';
import 'database_provider.dart';

/// Proxy URL for the chatbot (the Cloudflare Worker). Pass at build time with
/// `--dart-define=CHAT_PROXY_URL=https://<your-worker>.workers.dev`.
/// Empty by default so the app builds without a configured backend.
const String kChatProxyUrl =
    String.fromEnvironment('CHAT_PROXY_URL', defaultValue: '');

/// Singleton chat engine; holds the conversation for the session.
final chatEngineProvider = Provider<ChatEngine>((ref) {
  return ChatEngine(
    client: ChatClient(proxyUrl: kChatProxyUrl),
    executor: ChatToolExecutor(
      personRepo: ref.watch(personRepositoryProvider),
      profileRepo: ref.watch(profileRepositoryProvider),
    ),
  );
});
