import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/sharing/shared_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';

void main() {
  group('SharedProfile', () {
    test('encode/decode cycle', () {
      final original = SharedProfile(
        name: 'Test User',
        type: MbtiType.intj,
        confidence: 95,
      );

      final encoded = original.encode();
      final decoded = SharedProfile.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.name, 'Test User');
      expect(decoded.type, MbtiType.intj);
      expect(decoded.confidence, 95);
      expect(decoded.version, 'arc1');
    });

    test('decode from embedded text', () {
      const text = 'Hello, here is my profile: {"v":"arc1","n":"Embedded","t":"enfp","c":80} hope you like it!';
      final decoded = SharedProfile.decode(text);

      expect(decoded, isNotNull);
      expect(decoded!.name, 'Embedded');
      expect(decoded.type, MbtiType.enfp);
      expect(decoded.confidence, 80);
    });

    test('decode invalid json returns null', () {
      expect(SharedProfile.decode('invalid'), isNull);
      expect(SharedProfile.decode('{"v":"arc2"}'), isNull);
    });
  });
}
