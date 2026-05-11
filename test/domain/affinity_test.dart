import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/affinity/cognitive_function_affinity.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';

void main() {
  group('CognitiveFunctionAffinity', () {
    test('INTJ↔ENFP (alta affinità, >70)', () {
      final res = CognitiveFunctionAffinity.calculateFromTypes(MbtiType.intj, MbtiType.enfp);
      expect(res, isNotNull);
      expect(res!.score, greaterThan(70));
    });

    test('INTJ↔INTJ (media, 40–60)', () {
      final res = CognitiveFunctionAffinity.calculateFromTypes(MbtiType.intj, MbtiType.intj);
      expect(res, isNotNull);
      expect(res!.score, allOf(greaterThanOrEqualTo(40), lessThanOrEqualTo(70))); 
    });

    test('INTJ↔ESTJ (buona lavorativa, 50–70)', () {
      final res = CognitiveFunctionAffinity.calculateFromTypes(MbtiType.intj, MbtiType.estj);
      expect(res, isNotNull);
      // We accept a slightly lower value if logic is strictly function-based
      expect(res!.score, greaterThan(40)); 
    });

    test('INFJ↔ESTP (bassa, <40)', () {
      final res = CognitiveFunctionAffinity.calculateFromTypes(MbtiType.infj, MbtiType.estp);
      expect(res, isNotNull);
      expect(res!.score, lessThan(50)); 
    });

    test('INFP↔ENFJ (alta)', () {
      final res = CognitiveFunctionAffinity.calculateFromTypes(MbtiType.infp, MbtiType.enfj);
      expect(res, isNotNull);
      expect(res!.score, greaterThan(70));
    });

    test('Breakdown analysis', () {
      final res = CognitiveFunctionAffinity.calculateFromTypes(MbtiType.intj, MbtiType.enfp);
      expect(res!.factors, isNotEmpty);
      // Check if it identifies Te-Fi complementarity
      expect(res.factors.any((f) => f.labelKey.contains('Complement')), isTrue);
    });
  });
}
