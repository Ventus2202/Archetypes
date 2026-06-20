import 'dart:convert';

import 'chat_client.dart';
import 'chat_tools.dart';

/// Runs the OpenAI-style tool-calling loop for the chatbot. The conversation
/// and the tool execution live here, on the device; the proxy only relays each
/// chat-completions call to Workers AI. Tools execute locally against the
/// domain engines, so only minimal tool results (names, types, scores) ever
/// leave the device.
class ChatEngine {
  ChatEngine({required this.client, required this.executor});

  final ChatClient client;
  final ChatToolExecutor executor;

  static const int _maxToolRounds = 6;

  static const String _system = '''
Sei l'assistente di Archetypes, un'app che gestisce profili di personalità (MBTI) e le relazioni tra le persone in una mappa.
Rispondi a domande sulle persone nella mappa: affinità, coppie migliori, composizione di team, idoneità a ruoli.
Regole:
- Usa SEMPRE le funzioni (tool) per i calcoli. Non inventare mai punteggi, tipi MBTI o stack: provengono solo dai tool.
- "io"/"me" è la persona con "is_self": true (chiamala con list_people se serve un id).
- Se mancano dati (es. una persona non ha profilo MBTI), dillo chiaramente.
- Rispondi in italiano, in modo conciso e concreto, citando i punteggi che i tool restituiscono.
''';

  final List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get history => List.unmodifiable(_messages);

  bool get isConfigured => client.isConfigured;

  void reset() => _messages.clear();

  /// Sends a user message and returns the assistant's final text answer,
  /// driving the tool loop in between.
  Future<String> send(String userText) async {
    if (_messages.isEmpty) {
      _messages.add({'role': 'system', 'content': _system});
    }
    _messages.add({'role': 'user', 'content': userText});

    for (var round = 0; round < _maxToolRounds; round++) {
      final response =
          await client.complete(messages: _messages, tools: kChatTools);

      final choice = (response['choices'] as List).first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>;
      final toolCalls = message['tool_calls'] as List?;

      // Echo the assistant message back verbatim (must keep tool_calls).
      _messages.add({
        'role': 'assistant',
        'content': message['content'] ?? '',
        'tool_calls': ?toolCalls,
      });

      if (toolCalls == null || toolCalls.isEmpty) {
        final text = (message['content'] as String?)?.trim() ?? '';
        return text.isEmpty ? '(nessuna risposta)' : text;
      }

      for (final call in toolCalls.cast<Map<String, dynamic>>()) {
        final fn = call['function'] as Map<String, dynamic>;
        final result = await executor.execute(
          fn['name'] as String,
          _parseArgs(fn['arguments']),
        );
        _messages.add({
          'role': 'tool',
          'tool_call_id': call['id'],
          'content': result,
        });
      }
    }

    return 'Non sono riuscito a completare la richiesta (troppi passaggi).';
  }

  /// Tool-call arguments arrive as a JSON string (OpenAI shape) or, with some
  /// models, an already-decoded object.
  Map<String, dynamic> _parseArgs(Object? args) {
    if (args is Map) return args.cast<String, dynamic>();
    if (args is String && args.trim().isNotEmpty) {
      final decoded = jsonDecode(args);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    }
    return <String, dynamic>{};
  }
}
