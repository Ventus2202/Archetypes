import 'dart:convert';
import '../personality_systems/mbti/mbti_types.dart';

class SharedProfile {
  final String name;
  final MbtiType type;
  final int confidence;
  final String version;

  SharedProfile({
    required this.name,
    required this.type,
    required this.confidence,
    this.version = 'arc1',
  });

  Map<String, dynamic> toJson() => {
        'v': version,
        'n': name,
        't': type.name,
        'c': confidence,
      };

  String encode() => json.encode(toJson());

  static SharedProfile? decode(String text) {
    try {
      // Find the JSON block if it's embedded in other text
      final start = text.indexOf('{"v":"arc1"');
      if (start == -1) return null;
      
      int braceCount = 0;
      int end = -1;
      for (int i = start; i < text.length; i++) {
        if (text[i] == '{') {
          braceCount++;
        } else if (text[i] == '}') {
          braceCount--;
        }
        
        if (braceCount == 0) {
          end = i + 1;
          break;
        }
      }
      
      if (end == -1) return null;
      
      final jsonPart = text.substring(start, end);
      final data = json.decode(jsonPart) as Map<String, dynamic>;
      
      if (data['v'] != 'arc1') return null;
      
      final typeStr = (data['t'] as String).toLowerCase();
      final type = MbtiType.values.firstWhere((e) => e.name == typeStr);
      
      return SharedProfile(
        name: data['n'] as String,
        type: type,
        confidence: data['c'] as int,
        version: data['v'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}
