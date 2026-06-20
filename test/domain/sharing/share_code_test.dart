import 'dart:math';

import 'package:archetypes/domain/entities/personality_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/domain/sharing/share_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShareCode', () {
    test('encode produces a 24-character code', () {
      final code = ShareCode.generate(
        system: PersonalitySystem.mbti,
        type: MbtiType.intj,
        confidence: 85,
        source: ProfileSource.quizLong,
      );
      expect(code.encode().length, 24);
    });

    test('round-trips all fields', () {
      final original = ShareCode.generate(
        system: PersonalitySystem.mbti,
        type: MbtiType.enfp,
        confidence: 72,
        source: ProfileSource.manual,
        random: Random(1),
      );
      final decoded = ShareCode.decode(original.encode());
      expect(decoded, isNotNull);
      expect(decoded!.system, original.system);
      expect(decoded.type, original.type);
      expect(decoded.confidence, original.confidence);
      expect(decoded.source, original.source);
      expect(decoded.id, original.id);
    });

    test('encoding is deterministic for the same fields and id', () {
      final code = ShareCode(
        system: PersonalitySystem.mbti,
        type: MbtiType.istp,
        confidence: 50,
        source: ProfileSource.quizShort,
        id: List<int>.filled(9, 7),
      );
      expect(code.encode(), code.encode());
    });

    test('decoding is case-insensitive and tolerates I/L/O and spacing', () {
      final canonical = ShareCode.generate(
        system: PersonalitySystem.mbti,
        type: MbtiType.estj,
        confidence: 90,
        source: ProfileSource.granular,
        random: Random(42),
      ).encode();

      // Lowercase the code, then split into dash-separated groups.
      final messy = canonical.toLowerCase().replaceAllMapped(
            RegExp('.{4}'),
            (m) => '${m.group(0)}-',
          );
      final decoded = ShareCode.decode(messy);
      expect(decoded, isNotNull);
      expect(decoded!.encode(), canonical);
    });

    test('rejects a code with a corrupted character (checksum fails)', () {
      final code = ShareCode.generate(
        system: PersonalitySystem.mbti,
        type: MbtiType.infp,
        confidence: 60,
        source: ProfileSource.manual,
        random: Random(3),
      ).encode();

      // Flip the first character to a different valid symbol.
      final first = code[0];
      final replacement = first == 'Z' ? 'Y' : 'Z';
      final corrupted = replacement + code.substring(1);
      expect(corrupted == code, isFalse);
      expect(ShareCode.decode(corrupted), isNull);
    });

    test('rejects codes of the wrong length', () {
      expect(ShareCode.decode(''), isNull);
      expect(ShareCode.decode('ABC'), isNull);
      expect(ShareCode.decode('A' * 23), isNull);
      expect(ShareCode.decode('A' * 25), isNull);
    });

    test('rejects invalid Base32 symbols', () {
      // 'U' is not in the Crockford alphabet.
      expect(ShareCode.decode('U' * 24), isNull);
    });
  });
}
